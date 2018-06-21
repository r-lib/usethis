#' Connect a local repo with GitHub
#'
#' `use_github()` takes a local project, creates an associated repo on GitHub,
#' adds it to your local repo as the `origin` remote, and makes an initial push
#' to synchronize. `use_github()` requires that your project already be a Git
#' repository, which you can accomplish with [use_git()], if needed.
#'
#' @section Authentication:
#' A new GitHub repo will be created via the GitHub API, therefore you must
#' make a [GitHub personal access token
#' (PAT)](https://github.com/settings/tokens) available. You can either
#' provide this directly via the `auth_token` argument or store it in an
#' environment variable. Use [browse_github_pat()] to get help obtaining and
#' storing your PAT. See [gh::gh_whoami()] for even more detail.
#'
#' The argument `protocol` reflects how you wish to authenticate with GitHub
#' for this repo in the long run. This determines the form of the URL for the
#' `origin` remote:
#'   * `protocol = "ssh"`: `git@@github.com:<OWNER>/<REPO>.git`
#'   * `protocol = "https"`: `https://github.com/<OWNER>/<REPO>.git`
#'
#' For `protocol = "ssh"`, it is assumed that public and private keys are in the
#' default locations, `~/.ssh/id_rsa.pub` and `~/.ssh/id_rsa`, respectively, and
#' that `ssh-agent` is configured to manage any associated passphrase.
#' Alternatively, specify a [git2r::cred_ssh_key()] object via the `credentials`
#' parameter. Read more about ssh setup in [Happy
#' Git](http://happygitwithr.com/ssh-keys.html), especially the [troubleshooting
#' section](http://happygitwithr.com/ssh-keys.html#ssh-troubleshooting).
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
#' @param protocol transfer protocol, either "ssh" (the default) or "https"
#' @param credentials A [git2r::cred_ssh_key()] specifying specific ssh
#'   credentials or `NULL` for default ssh key and ssh-agent behaviour.
#' @export
#' @examples
#' \dontrun{
#' pkgpath <- file.path(tempdir(), "testpkg")
#' create_package(pkgpath) # creates package below temp directory
#'
#' ## now, working inside "testpkg", initialize git repository
#' use_git()
#'
#' ## create github repository and configure as git remote
#' use_github()                   ## to use default ssh protocol
#' use_github(protocol = "https") ## to use https
#' }
use_github <- function(organisation = NULL,
                       private = FALSE,
                       protocol = c("ssh", "https"),
                       credentials = NULL,
                       auth_token = NULL,
                       host = NULL) {
  check_uses_git()
  ## auth_token is used directly by git2r, therefore cannot be NULL
  auth_token <- auth_token %||% gh_token()
  check_gh_token(auth_token)

  if (uses_github(proj_get())) {
    done("GitHub is already initialized")
    return(invisible())
  }

  pkg <- project_data()
  repo_name <- pkg$Project %||% gsub("\n", " ", pkg$Package)
  repo_desc <- pkg$Title %||% ""

  if (interactive()) {
    todo("Check title and description")
    code_block(
      "Name:        {repo_name}",
      "Description: {repo_desc}",
      copy = FALSE
    )
    if (nope("Are title and description ok?")) {
      return(invisible())
    }
  } else {
    done("Setting title and description")
    code_block(
      "Name:        {repo_name}",
      "Description: {repo_desc}",
      copy = FALSE
    )
  }

  done("Creating GitHub repository")

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

  done("Adding GitHub remote")
  r <- git2r::repository(proj_get())
  protocol <- match.arg(protocol)
  origin_url <- switch(protocol,
    https = create$clone_url,
    ssh = create$ssh_url
  )
  git2r::remote_add(r, "origin", origin_url)

  if (is_package()) {
    done("Adding GitHub links to DESCRIPTION")
    use_github_links(auth_token = auth_token, host = host)
    if (git_uncommitted()) {
      git2r::add(r, "DESCRIPTION")
      git2r::commit(r, "Add GitHub links to DESCRIPTION")
    }
  }

  done("Pushing to GitHub and setting remote tracking branch")
  if (protocol == "ssh") {
    ## [1] push via ssh required for success setting remote tracking branch
    ## [2] to get passphrase from ssh-agent, you must use NULL credentials
    git2r::push(r, "origin", "refs/heads/master", credentials = credentials)
  } else { ## protocol == "https"
    ## in https case, when GITHUB_PAT is passed as password,
    ## the username is immaterial, but git2r doesn't know that.
    cred <- git2r::cred_user_pass("EMAIL", auth_token)
    git2r::push(r, "origin", "refs/heads/master", credentials = cred)
  }
  git2r::branch_set_upstream(git2r::repository_head(r), "origin/master")

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
  scopes <- collapse(scopes, ",")
  url <- sprintf(
    "%s/settings/tokens/new?scopes=%s&description=%s",
    host, scopes, description
  )
  view_url(url)
  todo(
    "Call {code('edit_r_environ()')} to open {value('.Renviron')} ",
    "and store your PAT with a line like:"
  )
  code_block("GITHUB_PAT=xxxyyyzzz", copy = FALSE)
  todo("Make sure {value('.Renviron')} ends with a newline!")
}

uses_github <- function(base_path = proj_get()) {
  tryCatch({
    gh_tree_remote(base_path)
    TRUE
  }, error = function(e) FALSE)
}


check_uses_github <- function(base_path = proj_get()) {
  if (uses_github(base_path)) {
    return(invisible())
  }

  stop_glue(
    "Cannot detect that package already uses GitHub.\n",
    "Do you need to run {code('use_github()')}?"
  )
}

## use from gh when/if exported
## https://github.com/r-lib/gh/issues/74
gh_token <- function() {
  token <- Sys.getenv('GITHUB_PAT', "")
  if (token == "") Sys.getenv("GITHUB_TOKEN", "") else token
}

check_gh_token <- function(auth_token) {
  if (is.null(auth_token) || !nzchar(auth_token)) {
    stop_glue(
      "No GitHub {code('auth_token')}.\n",
      "Provide explicitly or make available as an environment variable.\n",
      "See {code('browse_github_pat()')} for help setting this up."
    )
  }
  auth_token
}
