#' Get help with GitHub personal access tokens
#'
#' @description A [personal access
#' token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line)
#' (PAT) is needed for certain tasks usethis does via the GitHub API, such as
#' creating a repository, a fork, or a pull request. If you use HTTPS remotes,
#' your PAT is also used when interacting with GitHub as a conventional Git
#' remote. These functions help you get and manage your PAT:
#' * `gh_token_help()` guides you through token troubleshooting and setup
#' * `create_github_token()` opens a browser window to the GitHub form to
#'   generate a PAT, with suggested scopes pre-selected. It then offers advice
#'   on storing your PAT, which also appears below.
#' * `gitcreds::gitcreds_set()` helps you register your PAT with the Git
#'   credential manager used by your operating system. Later, other packages,
#'   such as usethis, gert, and gh can automatically retrieve that PAT, via
#'   `gitcreds::gitcreds_get()`, and use it to work with GitHub on your behalf.
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
#'   `gitcreds::gitcreds_set()` and `gitcreds::gitcreds_get()` for a secure way
#'   to store and retrieve your PAT.
#'
#' @return Nothing
#' @name github-token
NULL

#' @export
#' @rdname github-token
#' @examples
#' \dontrun{
#' create_github_token()
#' }
create_github_token <- function(scopes = c("repo", "user", "gist", "workflow"),
                                description = "R:GITHUB_PAT",
                                host = NULL) {
  scopes <- glue_collapse(scopes, ",")
  host <- host %||% get_hosturl(default_api_url())
  url <- glue(
    "{host}/settings/tokens/new?scopes={scopes}&description={description}"
  )
  withr::defer(view_url(url))

  ui_todo("
    Call {ui_code('gitcreds::gitcreds_set()')} to register this token in the \\
    local Git credential store
    It is also a great idea to store this token in any password-management \\
    software that you use")
  invisible()
}

#' @inheritParams use_github
#' @export
#' @rdname github-token
#' @examples
#' \dontrun{
#' gh_token_help()
#' }
gh_token_help <- function(host = NULL) {
  host_url <- get_hosturl(host %||% default_api_url())
  kv_line("GitHub host", host_url)

  bare_host <- sub("^https?://(.*)$", "\\1", host_url)
  online <- is_online(bare_host)
  kv_line("Host online", online)

  if (!online) {
    ui_oops("
      It is difficult to solve personal access token problems while offline
      Try again when {ui_value(host_url)} can be reached")
    return(invisible())
  }

  pat <- gh::gh_token(api_url = host_url)
  have_pat <- pat != ""
  if (have_pat) {
    kv_line("Personal access token for {ui_value(host_url)}", "<discovered>")
    host_hint <- if (is_github_dot_com(host_url)) "" else glue(".api_url = {host_url}")
    code_hint <- glue("gh::gh_whoami({host_hint})")
    ui_info("
      Call {ui_code(code_hint)} to see info about your token, e.g. the associated user")
    code_hint <- glue("gitcreds::gitcreds_set({host_hint})")
    ui_info("To see or update the token, call {ui_code(code_hint)}")
    ui_done("If those results are OK, you are good go to!")
    return(invisible())
  }
  ui_oops("No personal access token found for {ui_value(host_url)}")

  ui_todo("
    To create a personal access token, call {ui_code('create_github_token()')}")
  ui_todo("
    To store a token for current and future use, call \\
    {ui_code('gitcreds::gitcreds_set()')}")
}
