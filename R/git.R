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
use_git <- function(message = "Initial commit") {
  if (uses_git()) {
    return(invisible())
  }

  done("Initialising Git repo")
  r <- git2r::init(proj_get())

  use_git_ignore(c(".Rhistory", ".RData", ".Rproj.user"))

  done("Adding files and committing")
  paths <- unlist(git2r::status(r))
  git2r::add(r, paths)
  git2r::commit(r, message)

  restart_rstudio(
    "A restart of RStudio is required to activate the Git pane"
  )
  invisible(TRUE)

}

# Must be last command run
restart_rstudio <- function(message = NULL) {
  if (!in_rstudio(proj_get())) {
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

  rstudioapi::openProject(proj_get())
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
use_git_hook <- function(hook, script) {
  if (!uses_git()) {
    stop("This project doesn't use git", call. = FALSE)
  }

  base_path <- git2r::discover_repository(proj_get())
  use_directory(".git/hooks")

  hook_path <- file.path(".git/hooks", hook)
  write_over(base_path, hook_path, script)
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
use_git_ignore <- function(ignores, directory = ".") {
  write_union(proj_get(), file.path(directory, ".gitignore"), ignores)
}

uses_git <- function(path = proj_get()) {
  !is.null(git2r::discover_repository(path))
}

git_check_in <- function(base_path, paths, message) {
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
