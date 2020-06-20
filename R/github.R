#' Connect a local repo with GitHub
#'
#' @description
#' `use_github()` takes a local project and:
#' * Checks that the initial state is good to go:
#'   - Project is already a Git repo
#'   - Current branch is `master`
#'   - No uncommitted changes
#'   - No pre-existing `origin` remote
#' * Creates an associated repo on GitHub
#' * Adds that GitHub repo to your local repo as the `origin` remote
#' * Offers to commit changes, e.g. the addition of GitHub links to the
#'   URL and BugReports fields of DESCRIPTION
#' * Makes an initial push to GitHub
#' * Configures `origin/master` to be the upstream branch of the local `master`
#'   branch
#'
#' See the Authentication section below for general setup that is necessary for
#' all of this to work.
#'
#' @section Authentication:
#' This function interacts with GitHub in two different ways:
#' * via the GitHub REST API
#' * as a conventional Git remote
#' Therefore two types of auth happen.
#'
#' A new GitHub repo is created via the GitHub API, therefore you must make a
#' [GitHub personal access token (PAT)](https://github.com/settings/tokens)
#' available. There are two ways to provide the token, in order of preference:
#' * Configure your token as the `GITHUB_PAT` env var in `.Renviron`. Then it
#'   can be used by many packages and functions, without any effort on your
#'   part. If you don't have a token yet, see [browse_github_token()]. Remember
#'   that [edit_r_environ()] can help get `.Renviron` open for editing.
#' * Provide the token directly via the `auth_token` argument.
#'
#' The final push to GitHub means that regular Git credentials (for either the
#' SSH or HTTPS protocol) must also be available, just as `git push` on the
#' command line would require. usethis uses the gert package for git operations
#' (<https://docs.ropensci.org/gert>) and gert, in turn, relies on the
#' credentials package (<https://cran.r-project.org/package=credentials>) for
#' auth. In usethis v1.7.0, we switched from git2r to gert + credentials. This
#' pair of packages appears to be more successful in discovering and using the
#' same credentials as command line Git. As a result, a great deal of
#' credential-handling assistance has been removed from usethis. If you have
#' credential problems, focus your troubleshooting on getting the credentials
#' package to find your credentials. If you use the HTTPS protocol, a configured
#' `GITHUB_PAT` will satisfy both auth needs.
#'
#' @inheritParams use_git
#' @param organisation If supplied, the repo will be created under this
#'   organisation, instead of the account of the user associated with the
#'   `auth_token`. You must have permission to create repositories.
#' @param private If `TRUE`, creates a private repository.
#' @inheritParams git_protocol
#' @inheritParams git_credentials
#' @param host GitHub API host to use. Override with the endpoint-root for your
#'   GitHub enterprise instance, for example,
#'   "https://github.hostname.com/api/v3".
#' @param credentials \lifecycle{defunct}: No longer consulted now that usethis
#'   uses the gert package for Git operations, instead of git2r. Note that gert
#'   relies on the credentials package for auth.
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
                       auth_token = github_token(),
                       host = NULL,
                       credentials = deprecated()) {
  check_uses_git()
  # TODO: honor default_branch
  check_branch("master")
  check_no_uncommitted_changes()
  check_no_origin()
  check_github_token(auth_token)

  if (lifecycle::is_present(credentials)) {
    deprecate_warn_credentials("use_github")
  }

  owner <- organisation %||% github_user(auth_token)[["login"]]
  repo_name <- project_name()
  check_no_github_repo(owner, repo_name, host, auth_token)

  repo_desc <- project_data()$Title %||% ""
  repo_desc <- gsub("\n", " ", repo_desc)
  repo_spec <- glue("{owner}/{repo_name}")

  private_string <- if (private) "private" else ""
  ui_done("Creating {private_string} GitHub repository {ui_value(repo_spec)}")
  if (is.null(organisation)) {
    create <- gh::gh(
      "POST /user/repos",
      name = repo_name,
      description = repo_desc,
      private = private,
      .api_url = host,
      .token = auth_token
    )
  } else {
    create <- gh::gh(
      "POST /orgs/:org/repos",
      org = organisation,
      name = repo_name,
      description = repo_desc,
      private = private,
      .api_url = host,
      .token = auth_token
    )
  }

  origin_url <- switch(
    protocol,
    https = create$clone_url,
    ssh   = create$ssh_url
  )
  on.exit(view_url(create$html_url), add = TRUE)

  ui_done("Setting remote {ui_value('origin')} to {ui_value(origin_url)}")
  use_git_remote("origin", origin_url)

  if (is_package()) {
    error <- tryCatch(
      use_github_links(auth_token = auth_token, host = host),
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

  ui_done("
    Pushing {ui_value('master')} branch to GitHub and setting \\
    {ui_value('origin/master')} as upstream branch
    ")

  gert::git_push(remote = "origin", set_upstream = TRUE, repo = git_repo())

  invisible()
}

#' Use GitHub links in URL and BugReports
#'
#' Populates the `URL` and `BugReports` fields of a GitHub-using R package with
#' appropriate links. The ability to determine the correct URLs depends on
#' finding a fairly standard GitHub remote configuration.
#'
#' @inheritParams use_github
#' @export
#' @param overwrite By default, `use_github_links()` will not overwrite existing
#'   fields. Set to `TRUE` to overwrite existing links.
#' @examples
#' \dontrun{
#' use_github_links()
#' }
#'
use_github_links <- function(auth_token = github_token(),
                             host = "https://api.github.com",
                             overwrite = FALSE) {
  cfg <- classify_github_setup(auth_token = auth_token, host = host)
  if (cfg$unsupported) {
    stop_bad_github_config(cfg)
  }
  if (cfg$type %in% c("theirs", "fork_no_upstream") &&
      ui_github_config_wat(cfg)) {
    return(invisible())
  }

  if (cfg$type %in% c("ours", "theirs")) {
    remote <- cfg$origin
  } else { # cfg$type %in% c("fork", "fork_no_upstream")
    remote <- cfg$upstream
  }

  res <- gh::gh(
    "GET /repos/:owner/:repo",
    owner = remote$repo_owner,
    repo = remote$repo_name,
    .api_url = host,
    .token = check_github_token(auth_token, allow_empty = TRUE)
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
#' A [personal access
#' token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line)
#' (PAT) is needed for git operations via the GitHub API. Two helper functions
#' are provided:
#'   * `browse_github_token()` is synonymous with `browse_github_pat()`: Both
#'     open a browser window to the GitHub form to generate a PAT. See below for
#'     advice on how to store this.
#'   * `github_token()` retrieves a stored PAT by consulting, in this order:
#'     - `GITHUB_PAT` environment variable
#'     - `GITHUB_TOKEN` environment variable
#'     - the empty string `""`
#'
#' @section: Get and store a PAT:
#' Sign up for a free [GitHub.com](https://github.com/) account and sign in.
#' Call `browse_github_token()`. Verify the scopes and click "Generate token".
#' Copy the token right away! A common approach is to store in `.Renviron` as
#' the `GITHUB_PAT` environment variable. [edit_r_environ()] opens this file for
#' editing.
#'
#' @param scopes Character vector of token scopes, pre-selected in the web
#'   form. Final choices are made in the GitHub form. Read more about GitHub
#'   API scopes at
#'   <https://developer.github.com/apps/building-oauth-apps/scopes-for-oauth-apps/>.
#' @param description Short description or nickname for the token. It helps you
#'   distinguish various tokens on GitHub.
#' @inheritParams use_github
#'
#' @seealso [gh::gh_whoami()] for information on an existing token.
#'
#' @return `github_token()` returns a string, a GitHub PAT or `""`.
#' @export
#' @examples
#' \dontrun{
#' browse_github_token()
#' ## COPY THE PAT!!!
#' ## almost certainly to be followed by ...
#' edit_r_environ()
#' ## which helps you store the PAT as an env var
#' }
browse_github_token <- function(scopes = c("repo", "gist", "user:email"),
                                description = "R:GITHUB_PAT",
                                host = "https://github.com") {
  scopes <- glue_collapse(scopes, ",")
  url <- glue(
    "{host}/settings/tokens/new?scopes={scopes}&description={description}"
  )
  view_url(url)

  ui_todo(
    "Call {ui_code('usethis::edit_r_environ()')} to open {ui_path('.Renviron')}."
  )
  ui_todo("Store your PAT (personal access token) with a line like:")
  ui_code_block("GITHUB_PAT=xxxyyyzzz")
  ui_todo("Make sure {ui_value('.Renviron')} ends with a newline!")
  invisible()
}

#' @rdname browse_github_token
#' @export
browse_github_pat <- browse_github_token

#' @rdname browse_github_token
#' @export
#' @examples
#' # for safety's sake, just reveal first 4 characters
#' substr(github_token(), 1, 4)
github_token <- function() {
  token <- Sys.getenv("GITHUB_PAT", "")
  if (token == "") Sys.getenv("GITHUB_TOKEN", "") else token
}

## checks for existence of 'origin' remote with 'github' in URL
uses_github <- function() {
  if (!uses_git()) {
    return(FALSE)
  }
  length(github_origin()) > 0
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

check_uses_github <- function() {
  if (uses_github()) {
    return(invisible())
  }

  ui_stop(c(
    "This project does not have a GitHub remote configured as {ui_value('origin')}.",
    "Do you need to run {ui_code('use_github()')}?"
  ))
}

github_repo_exists <- function(owner, repo, host, auth_token) {
  tryCatch(
    error = function(err) FALSE,
    {
      gh::gh(
        "/repos/:owner/:repo",
        owner = owner, repo = repo,
        .api_url = host,
        .token = auth_token
      )
      TRUE
    }
  )
}

check_no_github_repo <- function(owner, repo, host, auth_token) {
  if (!github_repo_exists(owner, repo, host, auth_token)) {
    return(invisible())
  }
  spec <- paste(owner, repo, sep = "/")
  where <- if (is.null(host)) "github.com" else host
  ui_stop("Repo {ui_value(spec)} already exists on {ui_value(where)}.")
}


# github token helpers ----------------------------------------------------

## minimal check: token is not the value that means "we have no PAT",
## which is currently the empty string "", for compatibility with gh
have_github_token <- function(auth_token = github_token()) {
  !isTRUE(auth_token == "")
}

# TODO(@jennybc): this should be used / usable by git_sitrep(), which
# currently uses one-off code for checking the token

check_github_token <- function(auth_token = github_token(),
                               allow_empty = FALSE) {
  if (!is_online("github.com")) {
    ui_stop("Internet connection is not available")
  }

  if (allow_empty && !have_github_token(auth_token)) {
    return(invisible(auth_token))
  }

  local_stop <- function(msg) {
    ui_stop(c(
      msg,
      "See {ui_code('browse_github_token()')} for help storing a token as an environment variable."
    ))
  }

  if (!is_string(auth_token) || is.na(auth_token)) {
    local_stop("GitHub {ui_code('auth_token')} must be a single string.")
  }
  if (!have_github_token(auth_token)) {
    local_stop("No GitHub {ui_code('auth_token')} is available.")
  }
  user <- github_user(auth_token)
  if (is.null(user)) {
    local_stop("GitHub {ui_code('auth_token')} is invalid.")
  }
  invisible(auth_token)
}

## AFAICT there is no targetted way to check validity of a PAT
## GET /user seems to be the simplest API call to verify a PAT
## that's what gh::gh_whoami() does
## https://developer.github.com/v3/auth/#via-oauth-tokens
github_user <- function(auth_token = github_token()) {
  suppressMessages(
    tryCatch(gh::gh_whoami(auth_token), error = function(e) NULL)
  )
}
