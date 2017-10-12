#' Open useful configuration files
#'
#' * `edit_profile_user()` opens `~/.Rprofile`
#' * `edit_environ_user()` opens `~/.Renviron`
#' * `edit_makevars_user()` opens `~/.R/Makevars`
#' * `edit_git_config_user()` opens `~/.gitconfig`
#' * `edit_git_ignore_user()` opens `~/.gitignore`
#' * `edit_rstudio_snippets(type)` opens `~/R/snippets/{type}.snippets`
#'
#' @name edit
NULL

#' @export
#' @rdname edit
edit_profile_user <- function() {
  edit_file(".Rprofile", base_path = "~")
  todo("Restart R for changes to take effect")
  invisible()
}

#' @export
#' @rdname edit
edit_environ_user <- function() {
  edit_file(".Renviron", base_path = "~")
  todo("Restart R for changes to take effect")
  invisible()
}

#' @export
#' @rdname edit
edit_makevars_user <- function() {
  use_directory(".R", base_path = path.expand("~"))
  edit_file(".R/Makevars", base_path = "~")
  todo("Restart R for changes to take effect")
  invisible()
}

#' @export
#' @rdname edit
edit_git_config_user <- function() {
  edit_file(".gitconfig", base_path = "~")
  invisible()
}

#' @export
#' @rdname edit
edit_git_ignore_user <- function() {
  edit_file(".gitignore", base_path = "~")
  invisible()
}

#' @export
#' @rdname edit
#' @param type Snippet type. One of "R", "markdown", "C_Cpp", "Tex",
#'   "Javascript", "HTML", "SQL"
edit_rstudio_snippets <- function(type = "R") {
  edit_file(paste0(".R/snippets/", tolower(type), ".snippets"), base_path = "~")
  invisible()
}
