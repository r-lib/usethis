#' Connect a local repo with GitHub
#'
#' @description
#' `use_github()` takes a local project and:
#' * Checks that the initial state is good to go:
#'   - Project is already a Git repo
#'   - Current branch is the default branch, e.g. `main` or `master`
#'   - No uncommitted changes
#'   - No pre-existing `origin` remote
#' * Creates an associated repo on GitHub
#' * Adds that GitHub repo to your local repo as the `origin` remote
#' * Makes an initial push to GitHub
#' * Calls [use_github_links()], if the project is an R package
#' * Configures `origin/DEFAULT` to be the upstream branch of the local
#'   `DEFAULT` branch, e.g. `main` or `master`
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
#' @param visibility Only relevant for organisation-owned repos associated with
#'   certain GitHub Enterprise products. The special "internal" `visibility`
#'   grants read permission to all organisation members, i.e. it's intermediate
#'   between "private" and "public", within GHE. When specified, `visibility`
#'   takes precedence over `private = TRUE/FALSE`.
#' @inheritParams git_protocol
#' @param host GitHub host to target, passed to the `.api_url` argument of
#'   [gh::gh()]. If unspecified, gh defaults to "https://api.github.com",
#'   although gh's default can be customised by setting the GITHUB_API_URL
#'   environment variable.
#'
#'   For a hypothetical GitHub Enterprise instance, either
#'   "https://github.acme.com/api/v3" or "https://github.acme.com" is
#'   acceptable.
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
use_github <- function(
  organisation = NULL,
  private = FALSE,
  visibility = c("public", "private", "internal"),
  protocol = git_protocol(),
  host = NULL
) {
  visibility_specified <- !missing(visibility)
  visibility <- match.arg(visibility)
  check_protocol(protocol)
  check_uses_git()
  default_branch <- guess_local_default_branch()
  check_current_branch(
    is = default_branch,
    # glue-ing happens inside check_current_branch(), where `gb` gives the
    # current branch
    message = c(
      "x" = "Must be on the default branch {.val {is}}, not {.val {gb}}."
    )
  )
  challenge_uncommitted_changes(
    msg = "
    There are uncommitted changes and we're about to create and push to a new \\
    GitHub repo"
  )
  check_no_origin()

  if (is.null(organisation)) {
    if (visibility_specified) {
      ui_abort(
        "
        The {.arg visibility} setting is only relevant for organisation-owned
        repos, within the context of certain GitHub Enterprise products."
      )
    }
    visibility <- if (private) "private" else "public"
  }

  if (!is.null(organisation) && !visibility_specified) {
    visibility <- if (private) "private" else "public"
  }

  whoami <- suppressMessages(gh::gh_whoami(.api_url = host))
  if (is.null(whoami)) {
    ui_abort(c(
      "x" = "Unable to discover a GitHub personal access token.",
      "i" = "A token is required in order to create and push to a new repo.",
      "_" = "Call {.run usethis::gh_token_help()} for help configuring a token."
    ))
  }
  empirical_host <- parse_github_remotes(glue("{whoami$html_url}/REPO"))$host
  if (empirical_host != "github.com") {
    ui_bullets(c("i" = "Targeting the GitHub host {.val {empirical_host}}."))
  }

  owner <- organisation %||% whoami$login
  repo_name <- project_name()
  check_no_github_repo(owner, repo_name, host)

  repo_desc <- if (is_package()) proj_desc()$get_field("Title") %||% "" else ""
  repo_desc <- gsub("\n", " ", repo_desc)
  repo_spec <- glue("{owner}/{repo_name}")

  visibility_string <- if (visibility == "public") "" else glue("{visibility} ")
  ui_bullets(c(
    "v" = "Creating {visibility_string}GitHub repository {.val {repo_spec}}."
  ))
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
      visibility = visibility,
      # this is necessary to set `visibility` in GHE 2.22 (but not in 3.2)
      # hopefully it's harmless when not needed
      .accept = "application/vnd.github.nebula-preview+json",
      .api_url = host
    )
  }

  origin_url <- switch(
    protocol,
    https = create$clone_url,
    ssh = create$ssh_url
  )
  withr::defer(view_url(create$html_url))

  ui_bullets(c("v" = "Setting remote {.val origin} to {.val {origin_url}}."))
  use_git_remote("origin", origin_url)

  if (is_package()) {
    # we tryCatch(), because we can't afford any failure here to result in not
    # doing the first push and configuring the default branch
    # such an incomplete setup is hard to diagnose / repair post hoc
    tryCatch(
      use_github_links(),
      error = function(e) NULL
    )
  }

  git_push_first(default_branch, "origin")

  repo <- git_repo()
  gbl <- gert::git_branch_list(local = TRUE, repo = repo)
  if (nrow(gbl) > 1) {
    ui_bullets(c(
      "v" = "Setting {.val {default_branch}} as default branch on GitHub."
    ))
    gh::gh(
      "PATCH /repos/{owner}/{repo}",
      owner = owner,
      repo = repo_name,
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
#' @param overwrite By default, `use_github_links()` will not overwrite existing
#'   fields. Set to `TRUE` to overwrite existing links.
#' @export
#' @examples
#' \dontrun{
#' use_github_links()
#' }
#'
use_github_links <- function(overwrite = FALSE) {
  check_is_package("use_github_links()")

  gh_url <- github_url_from_git_remotes()

  proj_desc_field_update("URL", gh_url, overwrite = overwrite, append = TRUE)

  proj_desc_field_update(
    "BugReports",
    glue("{gh_url}/issues"),
    overwrite = overwrite
  )

  git_ask_commit(
    "Add GitHub links to DESCRIPTION",
    untracked = TRUE,
    paths = "DESCRIPTION"
  )

  invisible()
}

has_github_links <- function(target_repo = NULL) {
  url <- if (is.null(target_repo)) NULL else target_repo$url
  github_url <- github_url_from_git_remotes(url)
  if (is.null(github_url)) {
    return(FALSE)
  }

  desc <- proj_desc()

  has_github_url <- github_url %in% desc$get_urls()

  bug_reports <- desc$get_field("BugReports", default = character())
  has_github_issues <- glue("{github_url}/issues") %in% bug_reports

  has_github_url && has_github_issues
}

check_no_origin <- function() {
  remotes <- git_remotes()
  if ("origin" %in% names(remotes)) {
    ui_abort(c(
      "x" = "This repo already has an {.val origin} remote, with value
             {.val {remotes[['origin']]}}.",
      "i" = "You can remove this setting with:",
      " " = '{.code usethis::use_git_remote("origin", url = NULL, overwrite = TRUE)}'
    ))
  }
  invisible()
}

check_no_github_repo <- function(owner, repo, host) {
  spec <- glue("{owner}/{repo}")
  repo_found <- tryCatch(
    {
      repo_info <- gh::gh("/repos/{spec}", spec = spec, .api_url = host)
      # when does repo_info$full_name != the spec we sent?
      # this happens if you reuse the original name of a repo that has since
      # been renamed
      # there's no 404, because of the automatic redirect, but you CAN create
      # a new repo with this name
      # https://github.com/r-lib/usethis/issues/1893
      repo_info$full_name == spec
    },
    "http_error_404" = function(err) FALSE
  )
  if (!repo_found) {
    return(invisible())
  }
  empirical_host <- parse_github_remotes(repo_info$html_url)$host
  ui_abort("Repo {.val {spec}} already exists on {.val {empirical_host}}.")
}
