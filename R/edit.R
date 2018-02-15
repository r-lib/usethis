#' Open useful configuration files
#'
#' * `edit_r_profile()` opens `.Rprofile`
#' * `edit_r_environ()` opens `.Renviron`
#' * `edit_r_makevars()` opens `.R/Makevars`
#' * `edit_git_config()` opens `.gitconfig`
#' * `edit_git_ignore()` opens `.gitignore`
#' * `edit_rstudio_snippets(type)` opens `~/R/snippets/{type}.snippets`
#'
#' @param scope Edit globally for the current __user__, or locally for the
#'   current __project__
#' @name edit
NULL

#' @export
#' @rdname edit
edit_r_profile <- function(scope = c("user", "project")) {
  file <- file.path(scope_dir(scope), ".Rprofile")
  edit_file(file)
  todo("Restart R for changes to take effect")
  invisible(file)
}

#' @export
#' @rdname edit
edit_r_environ <- function(scope = c("user", "project")) {
  file <- file.path(scope_dir(scope), ".Renviron")
  edit_file(file)
  todo("Restart R for changes to take effect")
  invisible(file)
}

#' @export
#' @rdname edit
edit_r_makevars <- function(scope = c("user", "project")) {
  file <- file.path(scope_dir(scope), ".R/Makevars")
  edit_file(file)
  todo("Restart R for changes to take effect")
  invisible(file)
}

#' @export
#' @rdname edit
edit_git_config <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  path <- switch(scope, user = ".gitconfig", project = ".git/config")
  file <- file.path(git_scope_dir(scope), path = path)
  invisible(edit_file(file))
}

#' @export
#' @rdname edit
edit_git_ignore <- function(scope = c("user", "project")) {
  ## TODO(jennybc) https://github.com/r-lib/usethis/issues/182
  file <- file.path(git_scope_dir(scope), ".gitignore")
  invisible(edit_file(file))
}

#' @export
#' @rdname edit
#' @param type Snippet type. One of "R", "markdown", "C_Cpp", "Tex",
#'   "Javascript", "HTML", "SQL"
edit_rstudio_snippets <- function(type = "R") {
  file <- file.path("~", paste0(".R/snippets/", tolower(type), ".snippets"))
  invisible(edit_file(file))
}

scope_dir <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  message("Editing in ", field(scope), " scope")

  switch(scope, user = path.expand("~"), project = proj_get())
}

git_scope_dir <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  message("Editing in git ", field(scope), " scope")

  switch(scope, user = git_user_dot_home(), project = proj_get())
}

git_user_dot_home <- function() {
  if (.Platform$OS.type == "windows") {
    Sys.getenv("USERPROFILE")
  } else {
    path.expand("~")
  }
}
