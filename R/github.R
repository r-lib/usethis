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
#' @template double-auth
#'
#' @inheritParams use_git
#' @param organisation If supplied, the repo will be created under this
#'   organisation, instead of the account of the user associated with the
#'   `auth_token`. You must have permission to create repositories.
#' @param private If `TRUE`, creates a private repository.
#' @inheritParams git_protocol
#' @param auth_token GitHub personal access token (PAT).
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
  # this validates the token, so do it even if `organisation` is specified
  login <- github_login(auth_token)

  if (lifecycle::is_present(credentials)) {
    deprecate_warn_credentials("use_github")
  }

  owner <- organisation %||% login
  repo_name <- project_name()
  check_no_github_repo(owner, repo_name, host, auth_token)

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
    {ui_value('origin/master')} as upstream branch")

  gert::git_push(remote = "origin", set_upstream = TRUE, repo = git_repo())

  invisible()
}

#' Use GitHub links in URL and BugReports
#'
#' Populates the `URL` and `BugReports` fields of a GitHub-using R package with
#' appropriate links. The ability to determine the correct URLs depends on
#' finding a fairly standard GitHub remote configuration (`origin` only or
#' `origin` plus `upstream`).
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
                             host = NULL,
                             overwrite = FALSE) {
  check_is_package("use_github_links()")
  check_github_token(auth_token, allow_empty = TRUE)
  repo_spec <- repo_spec(auth_token = auth_token, host = host)

  res <- gh::gh(
    "GET /repos/:owner/:repo",
    owner = spec_owner(repo_spec),
    repo = spec_repo(repo_spec),
    .api_url = host,
    .token = auth_token
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
#'   generate a PAT. It then offers advice on storing your PAT, which also
#'   appears below.
#' * [credentials::set_github_pat()] helps you register your PAT with the Git
#'   credential manager used by your operating system. It can also use that PAT
#'   to set the `GITHUB_PAT` env var in an R session.
#' * `github_token()` retrieves a stored PAT by consulting, in this order:
#'   - `GITHUB_PAT` environment variable
#'   - `GITHUB_TOKEN` environment variable
#'   - the empty string `""`
#'
#' `create_github_token()` has previously gone by some other names:
#' `browse_github_token()` and `browse_github_pat()`.
#'
#' @details
#' Sign up for a free [GitHub.com](https://github.com/) account and sign in.
#' Call `create_github_token()`. Verify the scopes and click "Generate token".
#' Copy the token right away! A common approach is to store in `.Renviron` as
#' the `GITHUB_PAT` environment variable. [edit_r_environ()] opens this file for
#' editing.
#'
#' A more secure alternative is to call [credentials::set_github_pat()] which
#' prompts you for your PAT and stores it with the Git credential manager used
#' by your operating system. Once stored, a call to
#' [credentials::set_github_pat()] retrieves this value and assigns it to the
#' `GITHUB_PAT` environment variable. This would be a great thing to put in a
#' startup file to make your PAT available in all R sessions. Remember
#' [edit_r_profile()] is handy for editing your `.Rprofile`. The advantage of
#' this approach is that your PAT is never stored in regular file, as plain
#' text.
#'
#' @param scopes Character vector of token scopes, pre-selected in the web form.
#'   Final choices are made in the GitHub form. Read more about GitHub API
#'   scopes at
#'   <https://developer.github.com/apps/building-oauth-apps/scopes-for-oauth-apps/>.
#' @param description Short description or nickname for the token. It helps you
#'   distinguish various tokens on GitHub.
#' @inheritParams use_github
#'
#' @seealso [gh::gh_whoami()] for information on an existing token and
#'   [credentials::set_github_pat()] for a secure way to store and retrieve your
#'   PAT.
#'
#' @return `github_token()` returns a string, a GitHub PAT or `""`.
#' @export
#' @examples
#' \dontrun{
#' create_github_token()
#' # COPY THE PAT!!!
#' # almost certainly to be followed by ...
#' edit_r_environ()
#' # which helps you store the PAT as an env var
#' # or a call to
#' credentials::set_github_pat()
#' # which helps you store the PAT in the git credential store
#' }
create_github_token <- function(scopes = c("repo", "gist", "user:email"),
                                description = "R:GITHUB_PAT",
                                host = "https://github.com") {
  scopes <- glue_collapse(scopes, ",")
  url <- glue(
    "{host}/settings/tokens/new?scopes={scopes}&description={description}"
  )
  on.exit(view_url(url), add = TRUE)

  ui_todo("
    Call {ui_code('usethis::edit_r_environ()')} to open {ui_path('.Renviron')}.
    Store your PAT (personal access token) with a line like:
    {ui_code('GITHUB_PAT=xxxyyyzzz')}
    Make sure {ui_value('.Renviron')} ends with a newline!")
  ui_todo("
    For more secure storage, see {ui_code('credentials::set_github_pat()')}.")
  invisible()
}

#' @rdname create_github_token
#' @export
#' @examples
#' # for safety's sake, just reveal first 4 characters
#' substr(github_token(), 1, 4)
github_token <- function() {
  token <- Sys.getenv("GITHUB_PAT", "")
  if (token == "") Sys.getenv("GITHUB_TOKEN", "") else token
}

origin_is_on_github <- function() {
  if (!uses_git()) {
    return(FALSE)
  }
  nrow(github_remotes("origin", github_get = FALSE)) > 0
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

check_no_github_repo <- function(owner, repo, host, auth_token) {
  repo_found <- tryCatch(
    {
      gh::gh(
        "/repos/:owner/:repo",
        owner = owner, repo = repo,
        .api_url = host,
        .token = auth_token
      )
      TRUE
    },
    "http_error_404" = function(err) FALSE
  )
  if (!repo_found) {
    return(invisible())
  }
  spec <- glue("{owner}/{repo}")
  where <- host %||% "github.com"
  ui_stop("Repo {ui_value(spec)} already exists on {ui_value(where)}.")
}

# github token helpers ----------------------------------------------------

## minimal check: token is not the value that means "we have no PAT",
## which is currently the empty string "", for compatibility with gh
have_github_token <- function(auth_token = github_token()) {
  !isTRUE(auth_token == "")
}

# TODO: this should be used / usable by git_sitrep(), which
# currently uses one-off code for checking the token

check_github_token <- function(auth_token = github_token(),
                               allow_empty = FALSE) {
  if (!is_online("github.com")) {
    ui_stop("
      Internet connection is not available, which is necessary \\
      for GitHub API calls")
  }

  # When is it OK if the token is "", i.e. we don't have a token?
  # When we're READING info about a repo that's probably PUBLIC.
  # A token is nice-to-have, because of rate limits and because the repo might
  # be private.
  # But we will often succeed even without a token.
  if (allow_empty && !have_github_token(auth_token)) {
    return(invisible(NULL))
  }

  advice <-
    "See {ui_code('create_github_token()')} for help storing a token as an environment variable."
  if (!is_string(auth_token) || is.na(auth_token)) {
    ui_stop(c(
      "GitHub {ui_code('auth_token')} must be a single string.",
      advice
    ))
  }
  if (!have_github_token(auth_token)) {
    ui_stop(c(
      "No GitHub {ui_code('auth_token')} is available.",
      advice
    ))
  }

  # AFAICT there is no targetted way to check validity of a PAT
  # GET /user seems to be the simplest API call to verify a PAT
  # that's what gh::gh_whoami() does
  # https://developer.github.com/v3/auth/#via-oauth-tokens
  out <- tryCatch(
    list(user = gh::gh_whoami(auth_token), error = NULL),
    http_error_401 = function(e) ui_oops("Token is invalid."),
    error = function(e) list(user = NULL, error = e)
  )

  if (is.null(out$error)) {
    # since we have this info, might as well return it invisibly
    # used in github_login()
    return(invisible(out$user))
  }

  ui_stop(c(
    "Failed to validate the GitHub {ui_code('auth_token')}",
    out$error$message
  ))
}

github_login <- function(auth_token = github_token()) {
  # killing two birds with one stone:
  # it seems we have to use GET /user to validate the token
  # if that succeeds, then we already have the user info and extract login
  out <- check_github_token(auth_token)
  out$login
}
