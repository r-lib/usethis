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
#' provide this directly via the `auth_token` argument or store it in an
#' environment variable. Use [browse_github_pat()] to get help obtaining and
#' storing your PAT. See [gh::gh_whoami()] for even more detail.
#'
#' @inheritParams use_git
#' @param organisation If supplied, the repo will be created under this
#'   organisation. You must have access to create repositories.
#' @param auth_token Provide a personal access token (PAT) from
#'   <https://github.com/settings/tokens>. If `NULL`, will use the logic
#'   described in [gh::gh_whoami()] to look for a token stored in an environment
#'   variable. Use [browse_github_pat()] to help set up your PAT.
#' @param private If `TRUE`, creates a private repository.
#' @param host GitHub API host to use. Override with the endpoint-root for your
#'   GitHub enterprise instance, for example,
#'   "https://github.hostname.com/api/v3"
#' @inheritParams use_git_protocol
#' @param credentials Optional. If provided, must be the output of a git2r
#'   credential function, such as [git2r::cred_ssh_key()]. We recommend you rely
#'   on default behaviour, if possible.
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
                       protocol = NULL,
                       credentials = NULL,
                       auth_token = NULL,
                       host = NULL) {
  check_uses_git()
  check_branch("master")
  check_uncommitted_changes()
  check_no_origin()
  r <- git_repo()

  ## auth_token is used directly by git2r, therefore cannot be NULL
  auth_token <- auth_token %||% gh_token()
  check_gh_token(auth_token)
  protocol <- use_git_protocol(protocol)

  owner <- organisation %||% gh::gh_whoami(auth_token)[["login"]]
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

  origin_url <- switch(protocol,
    https = create$clone_url,
    ssh = create$ssh_url
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
  if (protocol == "https") {
    credentials <- credentials %||% git2r::cred_user_pass("EMAIL", auth_token)
  }
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
use_github_links <- function(auth_token = NULL,
                             host = "https://api.github.com",
                             overwrite = FALSE) {
  check_uses_github()

  res <- gh::gh(
    "GET /repos/:owner/:repo",
    owner = github_owner(),
    repo = github_repo(),
    .api_url = host,
    .token = auth_token
  )

  use_description_field("URL", res$html_url, overwrite = overwrite)
  use_description_field(
    "BugReports",
    paste0(res$html_url, "/issues"),
    overwrite = overwrite
  )

  invisible()
}

#' Create a GitHub personal access token
#'
#' Opens a browser window to the GitHub page where you can generate a [Personal
#' Access
#' Token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line).
#' Make sure you have signed up for a free [GitHub.com](https://github.com/)
#' account and that you are signed in. Click "Generate token" after you have
#' verified the scopes. Copy the token right away! You probably want to store it
#' in `.Renviron` as the `GITHUB_PAT` environment variable. [edit_r_environ()]
#' can help you do that. Use [gh::gh_whoami()] to get information on an existing
#' token.
#'
#' @param scopes Character vector of token permissions. These are just defaults
#'   that will be pre-selected in the web form. You can select the final values
#'   on the GitHub page. Read more about GitHub API scopes at
#'   <https://developer.github.com/apps/building-oauth-apps/scopes-for-oauth-apps/>.
#'
#' @param description Short description or nickname for the token. It helps you
#'   distinguish various tokens on GitHub.
#' @inheritParams use_github
#' @export
#' @examples
#' \dontrun{
#' browse_github_pat()
#' ## COPY THE PAT!!!
#' ## almost certainly to be followed by ...
#' edit_r_environ()
#' ## which helps you store the PAT as an env var
#' }
browse_github_pat <- function(scopes = c("repo", "gist"),
                              description = "R:GITHUB_PAT",
                              host = "https://github.com") {
  scopes <- glue_collapse(scopes, ",")
  url <- sprintf(
    "%s/settings/tokens/new?scopes=%s&description=%s",
    host, scopes, description
  )
  view_url(url)

  ui_todo("Call {ui_code('usethis::edit_r_environ()')} to open {ui_path('.Renviron')}")
  ui_todo("Store your PAT with a line like:")
  ui_code_block("GITHUB_PAT=xxxyyyzzz")
  ui_todo("Make sure {ui_value('.Renviron')} ends with a newline!")
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

## use from gh when/if exported
## https://github.com/r-lib/gh/issues/74
gh_token <- function() {
  token <- Sys.getenv("GITHUB_PAT", "")
  if (token == "") Sys.getenv("GITHUB_TOKEN", "") else token
}

check_gh_token <- function(auth_token) {
  if (is.null(auth_token) || !nzchar(auth_token)) {
    ui_stop(c(
      "No GitHub {ui_code('auth_token')}.",
      "Provide explicitly or make available as an environment variable.",
      "See {ui_code('browse_github_pat()')} for help setting this up."
    ))
  }
  auth_token
}
