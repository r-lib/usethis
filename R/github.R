#' Connect a local repo with GitHub
#'
#' `use_github()` takes a local project, creates an associated repo on GitHub,
#' adds it to your local repo as the `origin` remote, and makes an initial push
#' to synchronize. `use_github()` requires that your project already be a Git
#' repository, which you can accomplish with [use_git()], if needed. See the
#' Authentication section below for other necessary setup.
#'
#' @section Authentication:
#' A new GitHub repo will be created via the GitHub API, therefore you must
#' make a [GitHub personal access token
#' (PAT)](https://github.com/settings/tokens) available. You can either
#' provide this directly via the `auth_token` argument or store it for retrieval
#' with [github_token()].
#'
#' @inheritParams use_git
#' @param organisation If supplied, the repo will be created under this
#'   organisation, instead of the account of the user associated with the
#'   `auth_token`. You must have permission to create repositories.
#' @param private If `TRUE`, creates a private repository.
#' @inheritParams git_protocol
#' @inheritParams git2r_credentials
#' @param host GitHub API host to use. Override with the endpoint-root for your
#'   GitHub enterprise instance, for example,
#'   "https://github.hostname.com/api/v3".
#'
#' @export
#' @examples
#' \dontrun{
#' pkgpath <- file.path(tempdir(), "testpkg")
#' create_package(pkgpath) # creates package below temp directory
#' proj_set(pkgpath)
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
                       credentials = NULL,
                       auth_token = github_token(),
                       host = NULL) {
  check_uses_git()
  check_branch("master")
  check_uncommitted_changes()
  check_no_origin()
  check_github_token(auth_token)

  credentials <- credentials %||% git2r_credentials(protocol, auth_token)
  r <- git_repo()
  owner <- organisation %||% github_user(auth_token)[["login"]]
  repo_name <- project_name()
  check_no_github_repo(owner, repo_name, host, auth_token)

  repo_desc <- project_data()$Title %||% ""

  if (interactive()) {
    ui_todo("Check title and description")
    ui_code_block(
      "
      Name:        {repo_name}
      Description: {repo_desc}
      ",
      copy = FALSE
    )
    if (ui_nope("Are title and description ok?")) {
      return(invisible())
    }
  } else {
    ui_todo("Setting title and description")
    ui_code_block(
      "
      Name:        {repo_name}
      Description: {repo_desc}
      ",
      copy = FALSE
    )
  }
  ui_done("Creating GitHub repository")

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

  ui_done("Setting remote {ui_value('origin')} to {ui_value(origin_url)}")
  git2r::remote_add(r, "origin", origin_url)

  if (is_package()) {
    ui_done("Adding GitHub links to DESCRIPTION")
    use_github_links(auth_token = auth_token, host = host)
    if (git_uncommitted()) {
      git2r::add(r, "DESCRIPTION")
      git2r::commit(r, "Add GitHub links to DESCRIPTION")
    }
  }

  ui_done("Pushing {ui_value('master')} branch to GitHub and setting remote tracking branch")
  pushed <- tryCatch({
    git2r::push(r, "origin", "refs/heads/master", credentials = credentials)
    TRUE
  }, error = function(e) FALSE)
  if (pushed) {
    git2r::branch_set_upstream(git2r::repository_head(r), "origin/master")
  } else {
    ui_todo(c(
      "Failed to push and set tracking branch.",
      "This often indicates a problem with git2r and the credentials.",
      "Try this in the shell, to complete the set up:",
      "{ui_code('git push --set-upstream origin master')}"
    ))
  }

  view_url(create$html_url)

  invisible(NULL)
}

#' Use GitHub links in URL and BugReports
#'
#' Populates the `URL` and `BugReports` fields of a GitHub-using R package with
#' appropriate links.
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
  check_uses_github()

  res <- gh::gh(
    "GET /repos/:owner/:repo",
    owner = github_owner(),
    repo = github_repo(),
    .api_url = host,
    .token = check_github_token(auth_token, allow_empty = TRUE)
  )

  use_description_field("URL", res$html_url, overwrite = overwrite)
  use_description_field(
    "BugReports",
    paste0(res$html_url, "/issues"),
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
browse_github_token <- function(scopes = c("repo", "gist"),
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
  ui_todo("Store your PAT with a line like:")
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
  origin <- git_remote_find(rname = "origin")
  if (is.null(origin)) {
    return(invisible())
  }
  ui_stop(c(
    "This repo already has an {ui_value('origin')} remote, with value {ui_value(origin)}.",
    "How to remove this setting in the shell:",
    "{ui_code('git remote rm origin')}"
  ))
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
    error = function(err) FALSE, {
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

check_github_token <- function(auth_token = github_token(),
                               allow_empty = FALSE) {
  if (allow_empty && !have_github_token(auth_token)) {
    return(auth_token)
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
  auth_token
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
