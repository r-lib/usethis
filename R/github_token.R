#' Get help with GitHub personal access tokens
#'
#' @description

#' A [personal access
#' token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line)
#' (PAT) is needed for certain tasks usethis does via the GitHub API, such as
#' creating a repository, a fork, or a pull request. If you use HTTPS remotes,
#' your PAT is also used when interacting with GitHub as a conventional Git
#' remote. These functions help you get and manage your PAT:

#' * `gh_token_help()` guides you through token troubleshooting and setup.
#' * `create_github_token()` opens a browser window to the GitHub form to
#'   generate a PAT, with suggested scopes pre-selected. It also offers advice
#'   on storing your PAT.
#' * `gitcreds::gitcreds_set()` helps you register your PAT with the Git
#'   credential manager used by your operating system. Later, other packages,
#'   such as usethis, gert, and gh can automatically retrieve that PAT and use
#'   it to work with GitHub on your behalf.
#'
#' Usually, the first time the PAT is retrieved in an R session, it is cached in
#' an environment variable, for easier reuse for the duration of that R session.
#' After initial acquisition and storage, all of this should happen
#' automatically in the background. GitHub is encouraging the use of PATs that
#' expire after, e.g., 30 days, so prepare yourself to re-generate and re-store
#' your PAT periodically.
#'
#' Git/GitHub credential management is covered in a dedicated article: [Managing
#' Git(Hub)
#' Credentials](https://usethis.r-lib.org/articles/articles/git-credentials.html)
#'
#' @details
#' `create_github_token()` has previously gone by some other names:
#' `browse_github_token()` and `browse_github_pat()`.
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
                                description = "DESCRIBE THE TOKEN'S USE CASE",
                                host = NULL) {
  scopes <- glue_collapse(scopes, ",")
  host <- get_hosturl(host %||% default_api_url())
  url <- glue(
    "{host}/settings/tokens/new?scopes={scopes}&description={description}"
  )
  withr::defer(view_url(url))

  hint <- code_hint_with_host("gitcreds::gitcreds_set", host)
  ui_todo("
    Call {ui_code(hint)} to register this token in the \\
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

  pat_sitrep(host_url)
}

code_hint_with_host <- function(function_name, host = NULL, arg_name = NULL) {
  arg_hint <- function(host, arg_name) {
    if (is.null(host) || is_github_dot_com(host)) {
      return("")
    }
    if (is_null(arg_name)) {
      glue('"{host}"')
    } else {
      glue('{arg_name} = "{host}"')
    }
  }

  glue_chr("{function_name}({arg_hint(host, arg_name)})")
}

# workhorse behind gh_token_help() and called, possibly twice, in git_sitrep()
# hence the need for `scold_for_renviron = TRUE/FALSE`
pat_sitrep <- function(host = "https://github.com",
                       scold_for_renviron = TRUE) {
  if (scold_for_renviron) {
    scold_for_renviron()
  }

  maybe_pat <- purrr::safely(gh::gh_token)(api_url = host)
  if (is.null(maybe_pat$result)) {
    ui_oops("The PAT discovered for {ui_path(host)} has the wrong structure.")
    ui_inform(maybe_pat$error)
    return(invisible(FALSE))
  }
  pat <- maybe_pat$result
  have_pat <- pat != ""

  if (!have_pat) {
    kv_line("Personal access token for {ui_value(host)}", NULL)
    hint <- code_hint_with_host("create_github_token", host, "host")
    ui_todo("To create a personal access token, call {ui_code(hint)}")
    hint <- code_hint_with_host("gitcreds::gitcreds_set", host)
    ui_todo("To store a token for current and future use, call {ui_code(hint)}")
    ui_info("
      Read more in the {ui_value('Managing Git(Hub) Credentials')} article:
      https://usethis.r-lib.org/articles/articles/git-credentials.html")
    return(invisible(FALSE))
  }
  kv_line("Personal access token for {ui_value(host)}", "<discovered>")

  online <- is_online(host)
  if (!online) {
    ui_oops("
      Host is not reachable.
      No further vetting of the personal access token is possible.
      Try again when {ui_value(host)} can be reached.")
    return(invisible())
  }

  maybe_who <- purrr::safely(gh::gh_whoami)(.token = pat, .api_url = host)
  if (is.null(maybe_who$result)) {
    message <- "Can't get user information for this token."
    if (inherits(maybe_who$error, "http_error_401")) {
      message <- "
        Can't get user information for this token.
        The token may no longer be valid or perhaps it lacks the \\
        {ui_value('user')} scope."
    }
    ui_oops(message)
    ui_inform(maybe_who$error)
    return(invisible(FALSE))
  }
  who <- maybe_who$result

  kv_line("GitHub user", who$login)
  scopes <- who$scopes
  kv_line("Token scopes", who$scopes)
  scopes <- strsplit(scopes, ", ")[[1]]
  scold_for_scopes(scopes)

  maybe_emails <-
    purrr::safely(gh::gh)("/user/emails", .token = pat, .api_url = host)
  if (is.null(maybe_emails$result)) {
    ui_oops("
      Can't retrieve registered email addresses from GitHub.
      Consider re-creating your PAT with the {ui_value('user')} \\
      or at least {ui_value('user:email')} scope.")
  } else {
    emails <- maybe_emails$result
    addresses <- map_chr(
      emails,
      ~ if (.x$primary) glue_data(.x, "{email} (primary)") else .x[["email"]]
    )
    kv_line("Email(s)", addresses)
    ui_silence(
      de_facto_email <- git_cfg_get("user.email", "de_facto")
    )
    if (!any(grepl(de_facto_email, addresses))) {
      ui_oops("
        Local Git user's email ({ui_value(de_facto_email)}) doesn't appear to \\
        be registered with GitHub.")
    }
  }

  invisible(TRUE)
}

scold_for_renviron <- function() {
  renviron_path <- scoped_path_r("user", ".Renviron", envvar = "R_ENVIRON_USER")
  if (!file_exists(renviron_path)) {
    return(invisible())
  }

  renviron_lines <- read_utf8(renviron_path)
  fishy_lines <- grep("^GITHUB_(PAT|TOKEN).*=.+", renviron_lines, value = TRUE)
  if (length(fishy_lines) == 0) {
    return(invisible())
  }

  fishy_keys <- re_match(fishy_lines, "^(?<key>.+)=.+")$key
  # TODO: when I switch to cli, this is a good place for `!`
  # in general, lots below is suboptimal, but good enough for now
  ui_info(c(
    "{ui_path(renviron_path)} defines environment variable(s):",
    paste0("- ", fishy_keys),
    "This can prevent your PAT from being retrieved from the Git credential store."
  ))
  ui_info("
    If you are troubleshooting PAT problems, the root cause may be an old, \\
    invalid PAT defined in {ui_path(renviron_path)}.")
  ui_todo("Call {ui_code('edit_r_environ()')} to edit that file.")
  ui_info("
    For most use cases, it is better to NOT define the PAT in \\
    {ui_code('.Renviron')}.
    Instead, call {ui_code('gitcreds::gitcreds_set()')} to put the PAT into \\
    the Git credential store.")

  invisible()
}

scold_for_scopes <- function(scopes) {
  if (length(scopes) == 0) {
    ui_oops("
      Token has no scopes!
      {ui_code('create_github_token()')} defaults to the recommended scopes.")
    return(invisible())
  }

  # https://docs.github.com/en/free-pro-team@latest/developers/apps/scopes-for-oauth-apps
  # why these checks?
  # previous defaults for create_github_token(): repo, gist, user:email
  # more recently: repo, user, gist, workflow
  # (gist scope is a very weak recommendation)
  has_repo <- "repo" %in% scopes
  has_workflow <- "workflow" %in% scopes
  has_user_email <- "user" %in% scopes || "user:email" %in% scopes

  if (has_repo && has_workflow && has_user_email) {
    return(invisible())
  }

  # current design of the ui_*() functions makes this pretty hard :(
  suggestions <- c(
    if (!has_repo) {
      "- {ui_value('repo')}: needed to fully access user's repos"
    },
    if (!has_workflow) {
      "- {ui_value('workflow')}: needed to manage GitHub Actions workflow files"
    },
    if (!has_user_email) {
      "- {ui_value('user:email')}: needed to read user's email addresses"
    }
  )
  message <- c(
    "Token lacks recommended scopes:",
    suggestions,
    "Consider re-creating your PAT with the missing scopes.",
    "{ui_code('create_github_token()')} defaults to the recommended scopes."
  )
  ui_oops(glue_collapse(message, sep = "\n"))
}
