#' Initialise a git repository.
#'
#' @param message Message to use for first commit.
#' @param pkg Path to package. See \code{\link{as.package}} for more
#'   information.
#' @export
#' @examples
#' \dontrun{use_git()}
use_git <- function(message = "Initial commit", pkg = ".") {
  use_git_with_config(message = message, pkg = pkg)
}

use_git_with_config <- function(message, pkg, add_user_config = FALSE, quiet = FALSE) {
  pkg <- as.package(pkg)

  if (uses_git(pkg$path)) {
    message("* Git is already initialized")
    return(invisible())
  }

  if (!quiet) {
    message("* Initialising repo")
  }
  r <- git2r::init(pkg$path)

  if (add_user_config) {
    git2r::config(r, global = FALSE, user.name = "user", user.email = "user@email.xx")
  }

  use_git_ignore(c(".Rproj.user", ".Rhistory", ".RData"), pkg = pkg, quiet = quiet)

  if (!quiet) {
    message("* Adding files and committing")
  }
  paths <- unlist(git2r::status(r))
  git2r::add(r, paths)
  git2r::commit(r, message)

  invisible()
}

#' Add a git hook.
#'
#' @param hook Hook name. One of "pre-commit", "prepare-commit-msg",
#'   "commit-msg", "post-commit", "applypatch-msg", "pre-applypatch",
#'   "post-applypatch", "pre-rebase", "post-rewrite", "post-checkout",
#'   "post-merge", "pre-push", "pre-auto-gc".
#' @param script Text of script to run
#' @inheritParams use_git
#' @export
use_git_hook <- function(hook, script, pkg = ".") {
  pkg <- as.package(pkg)

  git_dir <- file.path(pkg$path, ".git")
  if (!file.exists(git_dir)) {
    stop("This project doesn't use git", call. = FALSE)
  }

  hook_dir <- file.path(git_dir, "hooks")
  if (!file.exists(hook_dir)) {
    dir.create(hook_dir)
  }

  hook_path <- file.path(hook_dir, hook)
  writeLines(script, hook_path)
  Sys.chmod(hook_path, "0744")
}


use_git_ignore <- function(ignores, directory = ".", base_path = ".", quiet = FALSE) {
  path <- file.path(base_path, directory, ".gitignore")
  union_write(path, ignores, quiet = quiet)

  invisible(TRUE)
}

