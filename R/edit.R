#' Open useful configuration files
#'
#' * `edit_r_profile()` opens `.Rprofile`
#' * `edit_r_environ()` opens `.Renviron`
#' * `edit_r_makevars()` opens `.R/Makevars`
#' * `edit_git_config()` opens `.gitconfig`
#' * `edit_git_ignore()` opens `.gitignore`
#' * `edit_rstudio_snippets(type)` opens `~/R/snippets/{type}.snippets`
#'
#' The `edit_r_*()` and `edit_rstudio_*()` functions consult R's notion of
#' user's home directory. The `edit_git_*()` functions inherit home directory
#' pbehaviour from the \pkg{fs} package; see [fs::path_home()] for more details.
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
  file <- edit_file(scoped_path(scope, ".Rprofile"))
  todo("Restart R for changes to take effect")
  invisible(file)
}

#' @export
#' @rdname edit
edit_r_environ <- function(scope = c("user", "project")) {
  file <- edit_file(scoped_path(scope, ".Renviron"))
  todo("Restart R for changes to take effect")
  invisible(file)
}

#' @export
#' @rdname edit
edit_r_makevars <- function(scope = c("user", "project")) {
  file <- edit_file(scoped_path(scope, ".R", "Makevars"))
  todo("Restart R for changes to take effect")
  invisible(file)
}

#' @export
#' @rdname edit
#' @param type Snippet type. One of: "R", "markdown", "C_Cpp", "Tex",
#'   "Javascript", "HTML", "SQL"
edit_rstudio_snippets <- function(type = "R") {
  file <- scoped_path(
    "user",
    ".R", "snippets", path_ext_set(tolower(type), "snippets")
  )
  invisible(edit_file(file))
}


# git files are special ----

#' @export
#' @rdname edit
edit_git_config <- function(scope = c("user", "project")) {
  path <- switch(
    scope,
    user = ".gitconfig",
    project = path(".git", "config")
  )
  invisible(edit_file(scoped_git_path(scope, path)))
}

#' @export
#' @rdname edit
edit_git_ignore <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  file <- git_ignore_path(scope)
  if (scope == "user" && !file_exists(file)) {
    done(
      "Adding new global gitignore to your git config: ",
      value(".gitignore")
    )
    git2r::config(global = TRUE, core.excludesfile = "~/.gitignore")
  }
  invisible(edit_file(file))
}

## .gitignore is more common, but .gitignore_global appears in some
## very prominent places --> we must allow for the latter, if pre-exists
git_ignore_path <- function(scope) {
  path <- scoped_git_path(scope, ".gitignore")
  if (scope == "project") {
    return(path)
  }
  if (!file_exists(path)) {
    alt_path <- scoped_git_path("user", ".gitignore_global")
    path <- if (file_exists(alt_path)) alt_path else path
  }
  path
}


scoped_path <- function(scope, ...) path(scope_dir(scope), ...)
scoped_git_path <- function(scope, ...) path(scope_git_dir(scope), ...)

## uses R's notion of user's home directory
scope_dir <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  switch(
    scope,
    user = path_home_r(),
    project = proj_get()
  )
}

## uses fs's notion of user's home directory
scope_git_dir <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  switch(
    scope,
    user = path_home(),
    project = proj_get()
  )
}
