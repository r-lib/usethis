#' Open useful configuration files
#'
#' * `edit_profile_user()` opens `~/.Rprofile`
#' * `edit_environ_user()` opens `~/.Renviron`
#' * `edit_makevars_users()` opens `~/.R/Makevars`
#' * `edit_git_config_user()` opens `~/.gitconfig`
#' * `edit_git_ignore_user()` opens `~/.gitignore`
#'
#' @name edit
NULL

#' @export
#' @rdname edit
edit_profile_user <- function() {
  edit_file(".Rprofile", base_path = "~")
}

#' @export
#' @rdname edit
edit_environ_user <- function() {
  edit_file(".Renviron", base_path = "~")
}

#' @export
#' @rdname edit
edit_makevars_user <- function() {
  use_directory(".R", base_path = path.expand("~"))
  edit_file(".R/Makevars", base_path = "~")
}

#' @export
#' @rdname edit
edit_git_config_user <- function() {
  edit_file(".gitconfig", base_path = "~")
}

#' @export
#' @rdname edit
edit_git_ignore_user <- function() {
  edit_file(".gitignore", base_path = "~")
}
