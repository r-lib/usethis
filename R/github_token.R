#' Get help with GitHub personal access tokens
#'
#' @description

#' A [personal access
#' token](https://docs.github.com/articles/creating-a-personal-access-token-for-the-command-line)
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
create_github_token <- function(
  scopes = c("repo", "user", "gist", "workflow"),
  description = "DESCRIBE THE TOKEN'S USE CASE",
  host = NULL
) {
  scopes <- glue_collapse(scopes, ",")
  host <- get_hosturl(host %||% default_api_url())
  url <- glue(
    "{host}/settings/tokens/new?scopes={scopes}&description={description}"
  )
  withr::defer(view_url(url))

  hint <- code_hint_with_host("gitcreds::gitcreds_set", host)
  message <- c(
    "_" = "Call {.run {hint}} to register this token in the local Git
           credential store."
  )
  if (is_linux()) {
    message <- c(
      message,
      "!" = "On Linux, it can be tricky to store credentials persistently.",
      "i" = "Read more in the {.href ['Managing Git(Hub) Credentials' article](https://usethis.r-lib.org/articles/articles/git-credentials.html)}."
    )
  }
  message <- c(
    message,
    "i" = "It is also a great idea to store this token in any
           password-management software that you use."
  )
  ui_bullets(message)
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

  pat_sitrep(host_url, scope = "project")
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
# scope determines if "global" or "de_facto" email is checked
pat_sitrep <- function(
  host = "https://github.com",
  scope = c("user", "project"),
  scold_for_renviron = TRUE
) {
  scope <- rlang::arg_match(scope)

  if (scold_for_renviron) {
    scold_for_renviron()
  }

  maybe_pat <- purrr::safely(gh::gh_token)(api_url = host)
  if (is.null(maybe_pat$result)) {
    ui_bullets(c(
      "x" = "The PAT discovered for {.url {host}} has the wrong structure."
    ))
    ui_bullets(c("i" = maybe_pat$error))
    return(invisible(FALSE))
  }
  pat <- maybe_pat$result
  have_pat <- pat != ""

  if (!have_pat) {
    kv_line("Personal access token for {.val {host}}", NULL)
    hint <- code_hint_with_host("usethis::create_github_token", host, "host")
    ui_bullets(c(
      "_" = "To create a personal access token, call {.run {hint}}."
    ))
    hint <- code_hint_with_host("gitcreds::gitcreds_set", host)
    url <- "https://usethis.r-lib.org/articles/articles/git-credentials.html"
    ui_bullets(c(
      "_" = "To store a token for current and future use, call {.run {hint}}.",
      "i" = "Read more in the {.href [Managing Git(Hub) Credentials]({url})} article."
    ))
    return(invisible(FALSE))
  }
  kv_line("Personal access token for {.val {host}}", ui_special("discovered"))

  online <- is_online(host)
  if (!online) {
    ui_bullets(c(
      "x" = "Host is not reachable.",
      " " = "No further vetting of the personal access token is possible.",
      "_" = "Try again when {.val {host}} can be reached."
    ))
    return(invisible())
  }

  maybe_who <- purrr::safely(gh::gh_whoami)(.token = pat, .api_url = host)
  if (is.null(maybe_who$result)) {
    message <- c("x" = "Can't get user information for this token.")
    if (inherits(maybe_who$error, "http_error_401")) {
      message <- c(
        message,
        "i" = "The token may no longer be valid or perhaps it lacks the
               {.val user} scope."
      )
    }
    message <- c(
      message,
      "i" = maybe_who$error$message
    )
    ui_bullets(message)
    return(invisible(FALSE))
  }
  who <- maybe_who$result

  kv_line("GitHub user", who$login)
  scopes <- strsplit(who$scopes, ", ")[[1]]
  kv_line("Token scopes", scopes)
  scold_for_scopes(scopes)

  maybe_emails <-
    purrr::safely(gh::gh)("/user/emails", .token = pat, .api_url = host)
  if (is.null(maybe_emails$result)) {
    ui_bullets(c(
      "x" = "Can't retrieve registered email addresses from GitHub.",
      "i" = "Consider re-creating your PAT with the {.val user} (or at least
             {.val user:email}) scope."
    ))
  } else {
    emails <- maybe_emails$result
    addresses <- map_chr(
      emails,
      \(x) if (x$primary) glue_data(x, "{email} (primary)") else x[["email"]]
    )
    kv_line("Email(s)", addresses)
    ui_silence(
      user <- git_user_get(where_from_scope(scope))
    )
    git_user_check(user)
    if (!is.null(user$email) && !any(grepl(user$email, addresses))) {
      ui_bullets(c(
        "x" = "Git user's email ({.val {user$email}}) doesn't appear to be
               registered with GitHub host."
      ))
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
  ui_bullets(c(
    "!" = "{.path {pth(renviron_path)}} defines{cli::qty(length(fishy_keys))}
           the environment variable{?s}:",
    bulletize(fishy_keys),
    "!" = "This can prevent your PAT from being retrieved from the Git
           credential store.",
    "i" = "If you are troubleshooting PAT problems, the root cause may be an
           old, invalid PAT defined in {.path {pth(renviron_path)}}.",
    "i" = "For most use cases, it is better to NOT define the PAT in
           {.file .Renviron}.",
    "_" = "Call {.run usethis::edit_r_environ()} to edit that file.",
    "_" = "Then call {.run gitcreds::gitcreds_set()} to put the PAT into
           the Git credential store."
  ))
  invisible()
}

scold_for_scopes <- function(scopes) {
  if (length(scopes) == 0) {
    ui_bullets(c(
      "x" = "Token has no scopes!",
      "i" = "Tokens initiated with {.fun create_github_token} default to the
             recommended scopes."
    ))
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

  suggestions <- c(
    "*" = if (!has_repo) "{.val repo}: needed to fully access user's repos",
    "*" = if (!has_workflow) {
      "{.val workflow}: needed to manage GitHub Actions workflow files"
    },
    "*" = if (!has_user_email) {
      "{.val user:email}: needed to read user's email addresses"
    }
  )
  message <- c(
    "!" = "Token lacks recommended scopes:",
    suggestions,
    "i" = "Consider re-creating your PAT with the missing scopes.",
    "i" = "Tokens initiated with {.fun usethis::create_github_token} default to the
           recommended scopes."
  )
  ui_bullets(message)
}

#' Lock and unlock a branch on GitHub
#'
#' @description
#' These functions lock and unlock a branch on GitHub so that it's not possible
#' for anyone to make any changes. This is used as part of the release process
#' to ensure that you don't accidentally merge any pull requests or push any
#' commits while you are waiting for CRAN to get back to you.
#'
#' You must be an admin or an owner of the repo in order to lock/unlock
#' a branch.
#'
#' @export
#' @param branch The branch to lock/unlock. If not supplied, uses the
#'   default branch which is usually "main" or "master".
gh_lock_branch <- function(branch = NULL) {
  cfg <- github_remote_config(github_get = TRUE)
  repo <- target_repo(cfg)
  branch <- branch %||% git_default_branch_(cfg)

  invisible(gh::gh(
    "PUT /repos/{owner}/{repo}/branches/{branch}/protection",
    owner = repo$repo_owner,
    repo = repo$repo_name,
    branch = branch,
    # required parameters
    required_status_checks = NA,
    enforce_admins = TRUE,
    required_pull_request_reviews = NA,
    restrictions = NA,
    # paramter that actually does what we want
    lock_branch = TRUE
  ))
}

#' @export
#' @rdname gh_lock_branch
gh_unlock_branch <- function(branch = NULL) {
  cfg <- github_remote_config(github_get = TRUE)
  repo <- target_repo(cfg)
  branch <- branch %||% git_default_branch_(cfg)

  invisible(gh::gh(
    "DELETE /repos/{owner}/{repo}/branches/{branch}/protection",
    owner = repo$repo_owner,
    repo = repo$repo_name,
    branch = branch
  ))
}
