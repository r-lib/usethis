#' Initialise a git repository.
#'
#' `use_git` initialises a git repository, adds important files
#' to `.gitignore`, and commits all files.
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

  done("Initialising Git repo")
  r <- git2r::init(base_path)

  use_git_ignore(
    c(".Rhistory", ".RData", ".Rproj.user"),
    base_path = base_path
  )

  done("Adding files and committing")
  paths <- unlist(git2r::status(r))
  git2r::add(r, paths)
  git2r::commit(r, message)

  restart_rstudio(
    "A restart of RStudio is required to activate the Git pane",
    base_path = base_path
  )
  invisible(TRUE)

}

# Must be last command run
restart_rstudio <- function(message = NULL, base_path = ".") {
  if (!in_rstudio(base_path)) {
    return(FALSE)
  }

  if (!interactive())
    return(FALSE)

  if (!is.null(message)) {
    todo(message)
  }

  if (!rstudioapi::hasFun("openProject"))
    return(FALSE)

  if (yesno(todo_bullet(), " Restart now?"))
    return(FALSE)

  rstudioapi::openProject(base_path)
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
  if (!uses_git(base_path)) {
    stop("This project doesn't use git", call. = FALSE)
  }

  git_dir <- git2r::discover_repository(base_path)
  use_directory("hooks", base_path = git_dir)

  hook_path <- file.path("hooks", hook)
  write_over(git_dir, hook_path, script)
  Sys.chmod(hook_path, "0744")

  invisible()
}

#' Tell git to ignore files
#'
#' @param ignores Character vector of ignores, specified as file globs.
#' @param directory Directory within `base_path` to set ignores
#' @inheritParams use_template
#' @family git helpers
#' @export
use_git_ignore <- function(ignores, directory = ".", base_path = ".") {
  write_union(base_path, file.path(directory, ".gitignore"), ignores)
}

uses_git <- function(path = ".") {
  !is.null(git2r::discover_repository(path))
}

git_check_in <- function(paths, message, base_path = ".") {
  if (!uses_git(base_path))
    return(invisible())

  if (!git_uncommitted(base_path))
    return(invisible())

  done("Checking into git [", message, "]")

  r <- git2r::init(base_path)
  git2r::add(r, paths)
  git2r::commit(r, message)

  invisible(TRUE)
}
