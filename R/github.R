#' Connect a local repo with GitHub.
#'
#' If the current repo does not use git, calls \code{\link{use_git}}
#' automatically. \code{\link{use_github_links}} is called to populate the
#' \code{URL} and \code{BugReports} fields of DESCRIPTION.
#'
#' @section Authentication:
#'
#'   A new GitHub repo will be created via the GitHub API, therefore you must
#'   provide a GitHub personal access token (PAT) via the argument
#'   \code{auth_token}, which defaults to the value of the \code{GITHUB_PAT}
#'   environment variable. Obtain a PAT from
#'   \url{https://github.com/settings/tokens}. The "repo" scope is required
#'   which is one of the default scopes for a new PAT.
#'
#'   The argument \code{protocol} reflects how you wish to authenticate with
#'   GitHub for this repo in the long run. For either \code{protocol}, a remote
#'   named "origin" is created, an initial push is made using the specified
#'   \code{protocol}, and a remote tracking branch is set. The URL of the
#'   "origin" remote has the form \code{git@@github.com:<USERNAME>/<REPO>.git}
#'   (\code{protocol = "ssh"}, the default) or
#'   \code{https://github.com/<USERNAME>/<REPO>.git} (\code{protocol =
#'   "https"}). For \code{protocol = "ssh"}, it is assumed that public and
#'   private keys are in the default locations, \code{~/.ssh/id_rsa.pub} and
#'   \code{~/.ssh/id_rsa}, respectively, and that \code{ssh-agent} is configured
#'   to manage any associated passphrase.  Alternatively, specify a
#'   \code{\link[git2r]{cred_ssh_key}} object via the \code{credentials}
#'   parameter.
#'
#' @inheritParams use_git
#' @param auth_token Provide a personal access token (PAT) from
#'   \url{https://github.com/settings/tokens}. Defaults to the \code{GITHUB_PAT}
#'   environment variable.
#' @param private If \code{TRUE}, creates a private repository.
#' @param host GitHub API host to use. Override with the endpoint-root for your
#'   GitHub enterprise instance, for example,
#'   "https://github.hostname.com/api/v3".
#' @param protocol transfer protocol, either "ssh" (the default) or "https"
#' @param credentials A \code{\link[git2r]{cred_ssh_key}} specifying specific
#' ssh credentials or NULL for default ssh key and ssh-agent behaviour.
#' Default is NULL.
#' @export
#' @examples
#' \dontrun{
#' ## to use default ssh protocol
#' create("testpkg")
#' use_github(pkg = "testpkg")
#'
#' ## or use https
#' create("testpkg2")
#' use_github(pkg = "testpkg2", protocol = "https")
#' }
use_github <- function(auth_token = github_pat(), private = FALSE, pkg = ".",
                       host = "https://api.github.com",
                       protocol = c("ssh", "https"), credentials = NULL) {

  if (is.null(auth_token)) {
    stop("GITHUB_PAT required to create new repo")
  }

  protocol <- match.arg(protocol)

  pkg <- as.package(pkg)
  use_git(pkg = pkg)

  if (uses_github(pkg$path)) {
    message("* GitHub is already initialized")
    return(invisible())
  }

  message("* Checking title and description")
  message("  Title: ", pkg$title)
  message("  Description: ", pkg$description)
  if (yesno("Are title and description ok?")) {
    return(invisible())
  }

  message("* Creating GitHub repository")
  create <-
    github_POST(
      "user/repos",
      pat = auth_token,
      body = list(
        name = jsonlite::unbox(pkg$package),
        description = jsonlite::unbox(gsub("\n", " ", pkg$title)),
        private = jsonlite::unbox(private)
      ),
      host = host
    )

  message("* Adding GitHub remote")
  r <- git2r::repository(pkg$path)
  origin_url <- switch(protocol, https = create$clone_url, ssh = create$ssh_url)
  git2r::remote_add(r, "origin", origin_url)

  message("* Adding GitHub links to DESCRIPTION")
  use_github_links(pkg$path, auth_token = auth_token, host = host)
  if (git_uncommitted(pkg$path)) {
    git2r::add(r, "DESCRIPTION")
    git2r::commit(r, "Add GitHub links to DESCRIPTION")
  }

  message("* Pushing to GitHub and setting remote tracking branch")
  if (protocol == "ssh") {
    ## [1] push via ssh required for success setting remote tracking branch
    ## [2] to get passphrase from ssh-agent, you must use NULL credentials
    git2r::push(r, "origin", "refs/heads/master", credentials = credentials)
  } else { ## protocol == "https"
    ## in https case, when GITHUB_PAT is passed as password,
    ## the username is immaterial, but git2r doesn't know that
    cred <- git2r::cred_user_pass("EMAIL", auth_token)
    git2r::push(r, "origin", "refs/heads/master", credentials = cred)
  }
  git2r::branch_set_upstream(git2r::head(r), "origin/master")

  message("* View repo at ", create$html_url)

  invisible(NULL)
}

#' Add GitHub links to DESCRIPTION.
#'
#' Populates the URL and BugReports fields of DESCRIPTION with
#' \code{https://github.com/<USERNAME>/<REPO>} AND
#' \code{https://github.com/<USERNAME>/<REPO>/issues}, respectively, unless
#' those fields already exist.
#'
#' @inheritParams use_git
#' @param auth_token Provide a personal access token (PAT) from
#'   \url{https://github.com/settings/tokens}. Defaults to the \code{GITHUB_PAT}
#'   environment variable.
#' @param host GitHub API host to use. Override with the endpoint-root for your
#'   GitHub enterprise instance, for example,
#'   "https://github.hostname.com/api/v3".
#' @export
use_github_links <- function(pkg = ".", auth_token = github_pat(),
                             host = "https://api.github.com") {

  if (!uses_github(pkg)) {
    stop("Cannot detect that package already uses GitHub.\n",
         "You might want to run use_github().")
  }

  gh_info <- github_info(pkg)
  pkg <- as.package(pkg)

  desc_path <- file.path(pkg$path, "DESCRIPTION")
  desc <- new_desc <- read_dcf(desc_path)

  path_to_repo <- paste("repos", gh_info$fullname, sep = "/")
  res <- github_GET(path = path_to_repo, pat = auth_token, host = host)
  github_URL <- res$html_url

  fill <- function(d, f, filler) {
    if (is.null(d[[f]]) || identical(d[[f]], "")) {
      d[[f]] <- filler
    } else {
      message("Existing ", f, " field found and preserved")
    }
    d
  }
  new_desc <- fill(new_desc, "URL", github_URL)
  new_desc <- fill(new_desc, "BugReports", file.path(github_URL, "issues"))

  if (!identical(desc, new_desc))
    write_dcf(desc_path, new_desc)

  new_desc[c("URL", "BugReports")]
}
