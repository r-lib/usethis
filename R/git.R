#' Initialise a git repository
#'
#' `use_git()` initialises a Git repository and adds important files to
#' `.gitignore`. If user consents, it also makes an initial commit.
#'
#' @param message Message to use for first commit.
#' @family git helpers
#' @export
#' @examples
#' \dontrun{
#' use_git()
#' }
use_git <- function(message = "Initial commit") {
  if (uses_git()) {
    return(invisible())
  }

  done("Initialising Git repo")
  r <- git2r::init(proj_get())

  use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user"))

  if (interactive() && git_uncommitted()) {
    paths <- unlist(git2r::status(r))
    commit_consent_msg <- glue(
      "OK to make an initial commit of {length(paths)} files?"
    )
    if (yep(commit_consent_msg)) {
      done("Adding files and committing")
      git2r::add(r, paths)
      git2r::commit(r, message)
    }
  }

  restart_rstudio(
    "A restart of RStudio is required to activate the Git pane"
  )
  invisible(TRUE)

}

#' Add a git hook
#'
#' Sets up a git hook using specified script. Creates hook directory if
#' needed, and sets correct permissions on hook.
#'
#' @param hook Hook name. One of "pre-commit", "prepare-commit-msg",
#'   "commit-msg", "post-commit", "applypatch-msg", "pre-applypatch",
#'   "post-applypatch", "pre-rebase", "post-rewrite", "post-checkout",
#'   "post-merge", "pre-push", "pre-auto-gc".
#' @param script Text of script to run
#' @family git helpers
#' @export
use_git_hook <- function(hook, script) {
  check_uses_git()

  hook_dir <- create_directory(proj_get(), ".git/hooks")
  hook_path <- path(hook_dir, hook)
  write_over(hook_path, script)
  file_chmod(hook_path, "0744")

  invisible()
}

#' Tell git to ignore files
#'
#' @param ignores Character vector of ignores, specified as file globs.
#' @param directory Directory relative to active project to set ignores
#' @family git helpers
#' @export
use_git_ignore <- function(ignores, directory = ".") {
  write_union(proj_path(directory, ".gitignore"), ignores)
}

#' Configure Git
#'
#' Sets Git options, for either the user or the project ("global" or "local", in
#' Git terminology). The mandate is currently very narrow: to manage the user
#' name and email. The `scope` argument is consulted when writing. When reading,
#' `use_git_config()` ignores `scope` and simply reports the options in effect,
#' where local config overrides global, if present. Use [git2r::config()]
#' directly or the command line for general Git configuration.
#'
#' @return  A list with components `user.name` and `user.email`.
#'
#' @inheritParams edit
#' @inheritParams git2r::config
#'
#' @family git helpers
#' @export
#' @examples
#' \dontrun{
#' ## see if user name and email are currently configured
#' use_git_config()
#'
#' ## set the user's global user.name and user.email
#' use_git_config(user.name = "Jane", user.email = "jane@example.org")
#'
#' ## set the user.name and user.email locally, i.e. for current repo/project
#' use_git_config(
#'   scope = "project",
#'   user.name = "Jane",
#'   user.email = "jane@example.org"
#' )
#' }
use_git_config <- function(scope = c("user", "project"), ...) {
  scope <- switch(match.arg(scope), user = "global", project = "local")

  if (length(list(...)) == 0) {
    if (uses_git()) {
      cfg <- git2r::config(repo = git2r::repository(proj_get()))
    } else {
      cfg <- git2r::config()
    }
  } else {
    done("Writing to {field(scope)} git config file")
    if (identical(scope, "global")) {
      cfg <- git2r::config(global = TRUE, ...)
    } else {
      check_uses_git()
      r <- git2r::repository(proj_get())
      cfg <- git2r::config(repo = r, global = FALSE, ...)
    }
  }

  local_cfg <- cfg[["local"]] %||% list()
  global_cfg <- cfg[["global"]] %||% list()
  cfg <- utils::modifyList(global_cfg, local_cfg)
  nms <- c("user.name", "user.email")
  return(stats::setNames(cfg[nms], nms))
}

uses_git <- function(path = proj_get()) {
  !is.null(git2r::discover_repository(path))
}

check_uses_git <- function(base_path = proj_get()) {
  if (uses_git(base_path)) {
    return(invisible())
  }

  stop_glue(
    "Cannot detect that project is already a Git repository.\n",
    "Do you need to run {code('use_git()')}?"
  )
}

git_check_in <- function(base_path, paths, message) {
  if (!uses_git(base_path))
    return(invisible())

  if (!git_uncommitted(base_path))
    return(invisible())

  done("Checking into git [{message}]")

  r <- git2r::repository(base_path)
  git2r::add(r, paths)
  git2r::commit(r, message)

  invisible(TRUE)
}
