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
#' * Offers to commit changes, e.g. the addition of GitHub links to the
#'   URL and BugReports fields of DESCRIPTION
#' * Makes an initial push to GitHub
#' * Configures `origin/DEFAULT` to be the upstream branch of the local
#'   `DEFAULT` branch, e.g. `master` or `main`
#'
#' See the Authentication section below for general setup that is necessary for
#' all of this to work.
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
#' @param host GitHub API host to use. Example for a GitHub Enterprise instance:
#'   "https://github.acme.com". It is also acceptable to provide the API root
#'   URL, e.g. "https://api.github.com" or "https://github.acme.com/api/v3".
#' @param auth_token,credentials \lifecycle{defunct}: No longer consulted now
#'   that usethis uses the gert package for Git operations, instead of git2r;
#'   gert relies on the credentials package for auth. The API requests are now
#'   authorized with the token associated with the `host`, as retrieved by
#'   [gitcreds::gitcreds_get()].
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
                       host = "https://github.com",
                       auth_token = deprecated(),
                       credentials = deprecated()) {
  check_uses_git()
  check_default_branch()
  check_no_uncommitted_changes()
  check_no_origin()

  if (lifecycle::is_present(auth_token)) {
    deprecate_warn_auth_token("use_github")
  }
  if (lifecycle::is_present(credentials)) {
    deprecate_warn_credentials("use_github")
  }

  host_url <- gh:::get_hosturl(host)
  api_url <- gh:::get_apiurl(host)
  auth_token <- gitcreds_token(host_url)
  if (auth_token == "") {
    get_code <- glue("gitcreds::gitcreds_get(\"{host_url}\")")
    set_code <- glue("gitcreds::gitcreds_set(\"{host_url}\")")
    ui_stop("
      Unable to discover a token for {ui_value(host_url)}
        Call {ui_code(get_code)} to experience this first-hand
        Call {ui_code(set_code)} to store a token")
  }
  who <- tryCatch(
    gh::gh_whoami(.token = auth_token, .api_url = api_url),
    http_error_401 = function(e) ui_stop("Token is invalid."),
    error = function(e) {
      ui_oops("
        Can't get login associated with this token. Is the network reachable?")
    }
  )
  login <- who$login

  owner <- organisation %||% login
  repo_name <- project_name()
  check_no_github_repo(owner, repo_name, api_url, auth_token)

  repo_desc <- project_data()$Title %||% ""
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
      .api_url = api_url, .token = auth_token
    )
  } else {
    create <- gh::gh(
      "POST /orgs/:org/repos",
      org = organisation,
      name = repo_name,
      description = repo_desc,
      private = private,
      .api_url = api_url, .token = auth_token
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
    error <- tryCatch(
      use_github_links(),
      usethis_error = function(e) e
    )
    if (!is.null(error)) {
      ui_oops("
        Unable to update the links in {ui_field('URL')} and/or \\
        {ui_field('BugReports')} in DESCRIPTION.
        Call \\
        {ui_code('usethis::use_github_links(overwrite = TRUE)')} to fix.")
    }
    if (git_uncommitted(untracked = FALSE)) {
      git_ask_commit(
        "Add GitHub links to DESCRIPTION",
        untracked = FALSE,
        paths = "DESCRIPTION"
      )
    }
  }

  default_branch <- git_branch_default()
  remref <- glue("origin/{default_branch}")
  ui_done("
    Pushing {ui_value(default_branch)} branch to GitHub and setting \\
    {ui_value(remref)} as upstream branch")
  gert::git_push(
    remote = "origin",
    set_upstream = TRUE,
    repo = git_repo(),
    verbose = FALSE
  )

  gbl <- gert::git_branch_list(repo = git_repo())
  gbl <- gbl[gbl$local, ]
  if (nrow(gbl) > 1) {
    ui_done("
      Setting {ui_value(default_branch)} as default branch on GitHub")
    gh::gh(
      "PATCH /repos/{owner}/{repo}",
      owner = owner, repo = repo_name,
      default_branch = default_branch,
      .api_url = api_url, .token = auth_token
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
#' @param host,auth_token \lifecycle{defunct}: No longer consulted now that
#'   usethis consults the current project's GitHub remotes to get the `host` and
#'   then uses the gitcreds package to obtain a matching token.
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
  cfg <- github_remote_config(github_get = TRUE)
  if (!cfg$type %in% c("ours", "fork")) {
    stop_bad_github_remote_config(cfg)
  }
  tr <- target_repo(cfg)

  res <- gh::gh(
    "GET /repos/:owner/:repo",
    owner = tr$repo_owner, repo = tr$repo_name,
    .api_url = tr$api_url, .token = tr$token
  )

  use_description_field("URL", res$html_url, overwrite = overwrite)
  use_description_field(
    "BugReports",
    glue("{res$html_url}/issues"),
    overwrite = overwrite
  )

  invisible()
}

#' Create and retrieve a GitHub personal access token
#'
#' @description A [personal access
#' token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line)
#' (PAT) is needed for certain tasks usethis does via the GitHub API, such as
#' creating a repository, a fork, or a pull request. If you use HTTPS remotes,
#' your PAT is also used when interacting with GitHub as a conventional Git
#' remote. These functions help you get and manage your PAT:
#' * `create_github_token()` opens a browser window to the GitHub form to
#'   generate a PAT, with suggested scopes pre-selected. It then offers advice
#'   on storing your PAT, which also appears below.
#' * [gitcreds::gitcreds_set()] helps you register your PAT with the Git
#'   credential manager used by your operating system. Later, other packages,
#'   such as usethis, gert, and gh can automatically retrieve that PAT, via
#'   [gitcreds::gitcreds_get()], and use it to work with GitHub on your behalf.
#'
#' Usually, the first time the PAT is retrieved in an R session, it is cached
#' in an environment variable, for easier reuse for the duration of that R
#' session. After initial acquisition and storage, all of this should happen
#' automatically in the background.
#'
#' `create_github_token()` has previously gone by some other names:
#' `browse_github_token()` and `browse_github_pat()`.
#'
#' @details
#' Sign up for a free [GitHub.com](https://github.com/) account and sign in.
#' Call `create_github_token()`. Verify the scopes and click "Generate token".
#' If you use a password management app, such as 1Password or LastPass, it is
#' highly recommended to add this PAT to your entry for GitHub. Storing your
#' PAT in the Git credential store is a semi-persistent convenience, sort of
#' like a browser cache, but it's quite possible you will need to re-provide it
#' at some point.
#'
#' @param scopes Character vector of token scopes, pre-selected in the web form.
#'   Final choices are made in the GitHub form. Read more about GitHub API
#'   scopes at
#'   <https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/>.
#' @param description Short description or nickname for the token. You might
#'   (eventually) have multiple tokens on your GitHub account and a label can
#'   help you keep track of what each token is for.
#' @inheritParams use_github
#'
#' @seealso [gh::gh_whoami()] for information on an existing token and
#'   [gitcreds::gitcreds_set()] and [gitcreds::gitcreds_get()] for a secure way
#'   to store and retrieve your PAT.
#'
#' @return Nothing
#' @export
#' @examples
#' \dontrun{
#' create_github_token()
#' }
create_github_token <- function(scopes = c("repo", "gist", "user:email"),
                                description = "R:GITHUB_PAT",
                                host = "https://github.com") {
  scopes <- glue_collapse(scopes, ",")
  url <- glue(
    "{host}/settings/tokens/new?scopes={scopes}&description={description}"
  )
  withr::defer(view_url(url))

  ui_todo("
    Call {ui_code('gitcreds::gitcreds_set()')} to register this token in the \\
    local Git credential store.
    It is also a great idea to store this token in any password-management \\
    software that you use.")
  invisible()
}

origin_is_on_github <- function() {
  if (!uses_git()) {
    return(FALSE)
  }
  nrow(github_remote_list("origin")) > 0
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

check_no_github_repo <- function(owner, repo, .api_url, .token) {
  repo_found <- tryCatch(
    {
      gh::gh(
        "/repos/:owner/:repo",
        owner = owner, repo = repo,
        .api_url = .api_url, .token = .token
      )
      TRUE
    },
    "http_error_404" = function(err) FALSE
  )
  if (!repo_found) {
    return(invisible())
  }
  spec <- glue("{owner}/{repo}")
  host_url <- gh:::get_hosturl(.api_url)
  ui_stop("Repo {ui_value(spec)} already exists on {ui_value(host_url)}.")
}
