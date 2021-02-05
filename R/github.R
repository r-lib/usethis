#' Connect a local repo with GitHub
#'
#' @description
#' `use_github()` takes a local project and:
#' * Checks that the initial state is good to go:
#'   - Project is already a Git repo
#'   - Current branch is the default branch, e.g. `master` or `main`
#'   - No uncommitted changes
#'   - No pre-existing `origin` remote
#' * Creates an associated repo on GitHub
#' * Adds that GitHub repo to your local repo as the `origin` remote
#' * Makes an initial push to GitHub
#' * Calls [use_github_links()], if the project is an R package
#' * Configures `origin/DEFAULT` to be the upstream branch of the local
#'   `DEFAULT` branch, e.g. `master` or `main`
#'
#' See below for the authentication setup that is necessary for all of this to
#' work.
#'
#' @template double-auth
#'
#' @param organisation If supplied, the repo will be created under this
#'   organisation, instead of the login associated with the GitHub token
#'   discovered for this `host`. The user's role and the token's scopes must be
#'   such that you have permission to create repositories in this
#'   `organisation`.
#' @param private If `TRUE`, creates a private repository.
#' @inheritParams git_protocol
#' @param host GitHub host to target, passed to the `.api_url` argument of
#'   [gh::gh()]. If unspecified, gh defaults to "https://api.github.com",
#'   although gh's default can be customised by setting the GITHUB_API_URL
#'   environment variable.
#'
#'   For a hypothetical GitHub Enterprise instance, either
#'   "https://github.acme.com/api/v3" or "https://github.acme.com" is
#'   acceptable.
#' @param auth_token,credentials `r lifecycle::badge("deprecated")`: No longer
#'   consulted now that usethis uses the gert package for Git operations,
#'   instead of git2r; gert relies on the credentials package for auth. The API
#'   requests are now authorized with the token associated with the `host`, as
#'   retrieved by [gh::gh_token()].
#'
#' @export
#' @examples
#' \dontrun{
#' pkgpath <- file.path(tempdir(), "testpkg")
#' create_package(pkgpath)
#'
#' ## now, working inside "testpkg", initialize git repository
#' use_git()
#'
#' ## create github repository and configure as git remote
#' use_github()
#' }
use_github <- function(organisation = NULL,
                       private = FALSE,
                       protocol = git_protocol(),
                       host = NULL,
                       auth_token = deprecated(),
                       credentials = deprecated()) {
  if (lifecycle::is_present(auth_token)) {
    deprecate_warn_auth_token("use_github")
  }
  if (lifecycle::is_present(credentials)) {
    deprecate_warn_credentials("use_github")
  }

  check_protocol(protocol)
  check_uses_git()
  check_default_branch()
  challenge_uncommitted_changes(msg = "
    There are uncommitted changes and we're about to create and push to a new \\
    GitHub repo")
  check_no_origin()

  whoami <- suppressMessages(gh::gh_whoami(.api_url = host))
  if (is.null(whoami)) {
    ui_stop("
      Unable to discover a GitHub personal access token
      A token is required in order to create and push to a new repo

      Call {ui_code('gh_token_help()')} for help configuring a token")
  }
  empirical_host <- parse_github_remotes(glue("{whoami$html_url}/REPO"))$host
  if (empirical_host != "github.com") {
    ui_info("Targeting the GitHub host {ui_value(empirical_host)}")
  }

  owner <- organisation %||%  whoami$login
  repo_name <- project_name()
  check_no_github_repo(owner, repo_name, host)

  repo_desc <- if (is_package()) package_data()$Title %||% "" else ""
  repo_desc <- gsub("\n", " ", repo_desc)
  repo_spec <- glue("{owner}/{repo_name}")

  private_string <- if (private) "private " else ""
  ui_done("Creating {private_string}GitHub repository {ui_value(repo_spec)}")
  if (is.null(organisation)) {
    create <- gh::gh(
      "POST /user/repos",
      name = repo_name,
      description = repo_desc,
      private = private,
      .api_url = host
    )
  } else {
    create <- gh::gh(
      "POST /orgs/{org}/repos",
      org = organisation,
      name = repo_name,
      description = repo_desc,
      private = private,
      .api_url = host
    )
  }

  origin_url <- switch(
    protocol,
    https = create$clone_url,
    ssh   = create$ssh_url
  )
  withr::defer(view_url(create$html_url))

  ui_done("Setting remote {ui_value('origin')} to {ui_value(origin_url)}")
  use_git_remote("origin", origin_url)

  if (is_package()) {
    # we tryCatch(), because we can't afford any failure here to result in not
    # making the first push and configuring default branch
    # such an incomplete setup is hard to diagnose / repair post hoc
    tryCatch(
      use_github_links(),
      error = function(e) NULL
    )
  }

  default_branch <- git_branch_default()
  repo <- git_repo()
  remref <- glue("origin/{default_branch}")
  ui_done("
    Pushing {ui_value(default_branch)} branch to GitHub and setting \\
    {ui_value(remref)} as upstream branch")
  gert::git_push(
    remote = "origin",
    set_upstream = TRUE,
    repo = repo,
    verbose = FALSE
  )

  gbl <- gert::git_branch_list(local = TRUE, repo = repo)
  if (nrow(gbl) > 1) {
    ui_done("
      Setting {ui_value(default_branch)} as default branch on GitHub")
    gh::gh(
      "PATCH /repos/{owner}/{repo}",
      owner = owner, repo = repo_name,
      default_branch = default_branch,
      .api_url = host
    )
  }

  invisible()
}

#' Use GitHub links in URL and BugReports
#'
#' @description
#' Populates the `URL` and `BugReports` fields of a GitHub-using R package with
#' appropriate links. The GitHub repo to link to is determined from the current
#' project's GitHub remotes:
#' * If we are not working with a fork, this function expects `origin` to be a
#'   GitHub remote and the links target that repo.
#' * If we are working in a fork, this function expects to find two GitHub
#'   remotes: `origin` (the fork) and `upstream` (the fork's parent) remote. In
#'   an interactive session, the user can confirm which repo to use for the
#'   links. In a noninteractive session, links are formed using `upstream`.
#'
#' @param host,auth_token `r lifecycle::badge("deprecated")`: No longer consulted
#'   now that usethis consults the current project's GitHub remotes to get the
#'   `host` and then relies on gh to discover an appropriate token.
#' @param overwrite By default, `use_github_links()` will not overwrite existing
#'   fields. Set to `TRUE` to overwrite existing links.
#' @export
#' @examples
#' \dontrun{
#' use_github_links()
#' }
#'
use_github_links <- function(auth_token = deprecated(),
                             host = deprecated(),
                             overwrite = FALSE) {
  if (lifecycle::is_present(auth_token)) {
    deprecate_warn_auth_token("use_github_links")
  }
  if (lifecycle::is_present(host)) {
    deprecate_warn_host("use_github_links")
  }

  check_is_package("use_github_links()")
  tr <- target_repo(github_get = TRUE)

  gh <- gh_tr(tr)
  res <- gh("GET /repos/{owner}/{repo}")

  use_description_field("URL", res$html_url, overwrite = overwrite)
  use_description_field(
    "BugReports",
    glue("{res$html_url}/issues"),
    overwrite = overwrite
  )

  git_ask_commit(
    "Add GitHub links to DESCRIPTION",
    untracked = TRUE,
    paths = "DESCRIPTION"
  )

  invisible()
}

check_no_origin <- function() {
  remotes <- git_remotes()
  if ("origin" %in% names(remotes)) {
    ui_stop("
      This repo already has an {ui_value('origin')} remote, \\
      with value {ui_value(remotes[['origin']])}.
      You can remove this setting with:
      {ui_code('usethis::use_git_remote(\"origin\", url = NULL, overwrite = TRUE)')}")
  }
  invisible()
}

check_no_github_repo <- function(owner, repo, host) {
  repo_found <- tryCatch(
    {
      repo_info <- gh::gh(
        "/repos/{owner}/{repo}",
        owner = owner, repo = repo,
        .api_url = host
      )
      TRUE
    },
    "http_error_404" = function(err) FALSE
  )
  if (!repo_found) {
    return(invisible())
  }
  spec <- glue("{owner}/{repo}")
  empirical_host <- parse_github_remotes(repo_info$html_url)$host
  ui_stop("Repo {ui_value(spec)} already exists on {ui_value(empirical_host)}")
}
