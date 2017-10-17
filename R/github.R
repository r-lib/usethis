#' Connect a local repo with GitHub.
#'
#' `use_github` calls [use_git()] if needed, creates
#' repo on github, then sets up appropriate git remotes and syncs.
#' `use_github_links` populates the `URL` and `BugReports`
#' fields with appropriate links (unless they already exist).
#'
#' @section Authentication:
#'
#'   A new GitHub repo will be created via the GitHub API, therefore you must
#'   provide a GitHub personal access token (PAT) via the argument
#'   `auth_token`, which defaults to the value of the `GITHUB_PAT`
#'   environment variable. Obtain a PAT from
#'   \url{https://github.com/settings/tokens}. The "repo" scope is required
#'   which is one of the default scopes for a new PAT.
#'
#'   The argument `protocol` reflects how you wish to authenticate with
#'   GitHub for this repo in the long run. For either `protocol`, a remote
#'   named "origin" is created, an initial push is made using the specified
#'   `protocol`, and a remote tracking branch is set. The URL of the
#'   "origin" remote has the form `git@@github.com:<USERNAME>/<REPO>.git`
#'   (`protocol = "ssh"`, the default) or
#'   `https://github.com/<USERNAME>/<REPO>.git` (\code{protocol =
#'   "https"}). For `protocol = "ssh"`, it is assumed that public and
#'   private keys are in the default locations, `~/.ssh/id_rsa.pub` and
#'   `~/.ssh/id_rsa`, respectively, and that `ssh-agent` is configured
#'   to manage any associated passphrase.  Alternatively, specify a
#'   [git2r::cred_ssh_key()] object via the `credentials`
#'   parameter.
#'
#' @inheritParams use_git
#' @param organisation If supplied, the repo will be created under this
#'   organisation. You must have access to create repositories.
#' @param auth_token Provide a personal access token (PAT) from
#'   \url{https://github.com/settings/tokens}. If `NULL`, will use the
#'   `GITHUB_PAT` environment variable.
#' @param private If `TRUE`, creates a private repository.
#' @param host GitHub API host to use. Override with the endpoint-root for your
#'   GitHub enterprise instance, for example,
#'   "https://github.hostname.com/api/v3". You can set this globally using
#'   the `GITHUB_API_URL` env var.
#' @param protocol transfer protocol, either "ssh" (the default) or "https"
#' @param credentials A [git2r::cred_ssh_key()] specifying specific
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
use_github <- function(organisation = NULL,
                       private = FALSE,
                       protocol = c("ssh", "https"),
                       credentials = NULL,
                       auth_token = NULL,
                       host = NULL) {

  if (!uses_git()) {
    stop("Please use_git() before use_github()", call. = FALSE)
  }

  if (uses_github(proj_get())) {
    done("GitHub is already initialized")
    return(invisible())
  }

  pkg <- project_data()
  repo_name <- pkg$Project %||% gsub("\n", " ", pkg$Package)
  repo_desc <- pkg$Title %||% ""

  todo("Check title and description")
  code_block(
    paste0("Name:        ", repo_name),
    paste0("Description: ", repo_desc),
    copy = FALSE
  )
  if (yesno("Are title and description ok?")) {
    return(invisible())
  }

  done("Creating GitHub repository")

  if (is.null(organisation)) {
    create <- gh::gh("POST /user/repos",
      name = repo_name,
      description = repo_desc,
      private = private,
      .api_url = host,
      .token = auth_token
    )
  } else {
    create <- gh::gh("POST /orgs/:org/repos",
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
    ## the username is immaterial, but git2r doesn't know that
    cred <- git2r::cred_user_pass("EMAIL", auth_token)
    git2r::push(r, "origin", "refs/heads/master", credentials = cred)
  }
  git2r::branch_set_upstream(git2r::head(r), "origin/master")

  view_url(create$html_url)

  invisible(NULL)
}

#' @export
#' @rdname use_github
use_github_links <- function(auth_token = NULL,
                             host = "https://api.github.com") {

  check_uses_github()

  info <- gh::gh_tree_remote()
  res <- gh::gh(
    "GET /repos/:owner/:repo",
    owner = info$username,
    repo = info$repo,
    .api_url = host,
    .token = auth_token
  )

  use_description_field("URL", res$html_url)
  use_description_field("BugReports", file.path(res$html_url, "issues"))

  invisible()
}


uses_github <- function(base_path = proj_get()) {
  tryCatch({
    gh::gh_tree_remote(base_path)
    TRUE
  }, error = function(e) FALSE)
}


check_uses_github <- function(base_path = proj_get()) {
  if (uses_github(base_path)) {
    return()
  }

  stop(
    "Cannot detect that package already uses GitHub.\n",
    "Do you need to run ", code("use_github()"), "?",
    call. = FALSE
  )
}
