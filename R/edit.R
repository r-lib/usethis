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
  edit_file(scope_dir(scope), ".Rprofile")
  todo("Restart R for changes to take effect")
  invisible()
}

#' @export
#' @rdname edit
edit_r_environ <- function(scope = c("user", "project")) {
  edit_file(scope_dir(scope), ".Renviron")
  todo("Restart R for changes to take effect")
  invisible()
}

#' @export
#' @rdname edit
edit_r_makevars <- function(scope = c("user", "project")) {
  dir <- scope_dir(scope)
  create_directory(dir, ".R")
  edit_file(dir, ".R/Makevars")
  todo("Restart R for changes to take effect")
  invisible()
}

#' @export
#' @rdname edit
edit_git_config <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  switch(scope,
    user = edit_file("~", ".gitconfig"),
    project = edit_file(proj_get(), ".git/config")
  )

  invisible()
}

#' @export
#' @rdname edit
edit_git_ignore <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  edit_file(scope_dir(scope), ".gitignore")
  invisible()
}

#' @export
#' @rdname edit
#' @param type Snippet type. One of "R", "markdown", "C_Cpp", "Tex",
#'   "Javascript", "HTML", "SQL"
edit_rstudio_snippets <- function(type = "R") {
  edit_file("~", paste0(".R/snippets/", tolower(type), ".snippets"))
  invisible()
}

scope_dir <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  message("Editing in ", scope, " scope")

  switch(scope, user = path.expand("~"), project = proj_get())
}
