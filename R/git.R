#' Initialise a git repository.
#'
#' \code{use_git} initialises a git repository, adds important files
#' to \code{.gitignore}, and commits all files.
#'
#' @param message Message to use for first commit.
#' @inheritParams use_template
#' @family git helpers
#' @export
#' @examples
#' \dontrun{use_git()}
use_git <- function(message = "Initial commit", base_path = ".") {
  if (uses_git(base_path)) {
    return(invisible())
  }

  message("* Initialising repo")
  r <- git2r::init(base_path)

  use_git_ignore(c(".Rhistory", ".RData"), base_path = base_path)

  message("* Adding files and committing")
  paths <- unlist(git2r::status(r))
  git2r::add(r, paths)
  git2r::commit(r, message)
}

#' Add a git hook.
#'
#' Sets up a git hook using specified script. Creates hook directory if
#' needed, and sets correct permissions on hook.
#'
#' @param hook Hook name. One of "pre-commit", "prepare-commit-msg",
#'   "commit-msg", "post-commit", "applypatch-msg", "pre-applypatch",
#'   "post-applypatch", "pre-rebase", "post-rewrite", "post-checkout",
#'   "post-merge", "pre-push", "pre-auto-gc".
#' @param script Text of script to run
#' @inheritParams use_template
#' @family git helpers
#' @export
use_git_hook <- function(hook, script, base_path = ".") {
  if (uses_git(base_path)) {
    stop("This project doesn't use git", call. = FALSE)
  }

  base_path <- git2r::discover_repository(base_path)
  use_directory(".git/hooks", base_path = base_path)

  hook_path <- file.path(base_path, ".git/hooks", hook)
  write_over(script, hook_path)
  Sys.chmod(hook_path, "0744")

  invisible()
}

#' Tell git to ignore files
#'
#' @param ignores Character vector of ignores, specified as file globs.
#' @param directory Directory within \code{base_path} to set ignores
#' @inheritParams use_template
#' @family git helpers
use_git_ignore <- function(ignores, directory = ".", base_path = ".") {
  path <- file.path(base_path, directory, ".gitignore")
  write_union(path, ignores)

  invisible(TRUE)
}

uses_git <- function(path = ".") {
  !is.null(git2r::discover_repository(path))
}
