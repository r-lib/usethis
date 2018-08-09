#' Open file for editing
#'
#' Opens a file for editing in RStudio, if that is the active environment, or
#' via [utils::file.edit()] otherwise. If the file does not exist, it is
#' created. If the parent directory does not exist, it is also created.
#'
#' @param path Path to target file.
#'
#' @return Target path, invisibly.
#' @export
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' edit_file("DESCRIPTION")
#' edit_file("~/.gitconfig")
#' }
edit_file <- function(path) {
  path <- user_path_prep(path)
  dir_create(path_dir(path), recursive = TRUE)
  file_create(path)

  if (!interactive() || is_testing()) {
    todo("Edit {(proj_rel_path(path))}")
  } else {
    todo("Modify {value(proj_rel_path(path))}")

    if (rstudioapi::isAvailable() && rstudioapi::hasFun("navigateToFile")) {
      rstudioapi::navigateToFile(path)
    } else {
      utils::file.edit(path)
    }
  }
  invisible(path)
}

#' Open configuration files
#'
#' * `edit_r_profile()` opens `.Rprofile`
#' * `edit_r_environ()` opens `.Renviron`
#' * `edit_r_makevars()` opens `.R/Makevars`
#' * `edit_git_config()` opens `.gitconfig` or `.git/config`
#' * `edit_git_ignore()` opens `.gitignore`
#' * `edit_rstudio_snippets(type)` opens `.R/snippets/{type}.snippets`
#'
#' The `edit_r_*()` and `edit_rstudio_*()` functions consult R's notion of
#' user's home directory. The `edit_git_*()` functions -- and \pkg{usethis} in
#' general -- inherit home directory behaviour from the \pkg{fs} package, which
#' differs from R itself on Windows. The \pkg{fs} default is more conventional
#' in terms of the location of user-level Git config files. See
#' [fs::path_home()] for more details.
#'
#' @return Path to the file, invisibly.
#'
#' @param scope Edit globally for the current __user__, or locally for the
#'   current __project__
#' @name edit
NULL

#' @export
#' @rdname edit
edit_r_profile <- function(scope = c("user", "project")) {
  file <- edit_file(scoped_path_r(scope, ".Rprofile"))
  todo("Restart R for changes to take effect")
  invisible(file)
}

#' @export
#' @rdname edit
edit_r_environ <- function(scope = c("user", "project")) {
  file <- edit_file(scoped_path_r(scope, ".Renviron"))
  todo("Restart R for changes to take effect")
  invisible(file)
}

#' @export
#' @rdname edit
edit_r_makevars <- function(scope = c("user", "project")) {
  file <- edit_file(scoped_path_r(scope, ".R", "Makevars"))
  todo("Restart R for changes to take effect")
  invisible(file)
}

#' @export
#' @rdname edit
#' @param type Snippet type. One of: "R", "markdown", "C_Cpp", "Tex",
#'   "Javascript", "HTML", "SQL"
edit_rstudio_snippets <- function(type = "R") {
  file <- scoped_path_r(
    "user",
    ".R", "snippets", path_ext_set(tolower(type), "snippets")
  )
  invisible(edit_file(file))
}

# git files are special ----

#' @export
#' @rdname edit
edit_git_config <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  path <- switch(
    scope,
    user = ".gitconfig",
    project = path(".git", "config")
  )
  invisible(edit_file(scoped_path_fs(scope, path)))
}

#' @export
#' @rdname edit
edit_git_ignore <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  file <- git_ignore_path(scope)
  if (scope == "user" && !file_exists(file)) {
    done("Creating new global gitignore: {value(file)}")
    git2r::config(
      global = TRUE,
      core.excludesfile = path("~", path_rel(file, scope_dir_fs(scope)))
    )
  }
  invisible(edit_file(file))
}

## .gitignore is more common, but .gitignore_global appears in some
## very prominent places --> we must allow for the latter, if pre-exists
git_ignore_path <- function(scope) {
  path <- scoped_path_fs(scope, ".gitignore")
  if (scope == "project") {
    return(path)
  }
  if (!file_exists(path)) {
    alt_path <- scoped_path_fs("user", ".gitignore_global")
    path <- if (file_exists(alt_path)) alt_path else path
  }
  path
}


scoped_path_r  <- function(scope, ...) path(scope_dir_r(scope), ...)
scoped_path_fs <- function(scope, ...) path(scope_dir_fs(scope), ...)

## uses R's notion of user's home directory, via fs::path_home_r()
scope_dir_r <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  switch(
    scope,
    user = path_home_r(),
    project = proj_get()
  )
}

## uses fs's notion of user's home directory, via fs:path_home()
scope_dir_fs <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  switch(
    scope,
    user = path_home(),
    project = proj_get()
  )
}
