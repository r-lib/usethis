#' Use a directory
#'
#' `use_directory()` creates a directory (if it does not already exist) in the
#' project's top-level directory. This function powers many of the other `use_`
#' functions such as [use_data()] and [use_vignette()].
#'
#' @param path Path of the directory to create, relative to the project.
#' @inheritParams use_template
#'
#' @export
#' @examples
#' \dontrun{
#' use_directory("inst")
#' }
use_directory <- function(path,
                          ignore = FALSE) {
  create_directory(proj_path(path))
  if (ignore) {
    use_build_ignore(path)
  }

  invisible(TRUE)
}

create_directory <- function(path) {
  if (dir_exists(path)) {
    return(invisible(FALSE))
  } else if (file_exists(path)) {
    stop_glue("{value(path)} exists but is not a directory.")
  }

  ui_done("Creating {value(path, '/')}")
  dir_create(path, recursive = TRUE)
  invisible(TRUE)
}

check_path_is_directory <- function(path) {
  if (!file_exists(path)) {
    stop_glue("{value(path)} does not exist.")
  }

  if (!is_dir(path)) {
    stop_glue("{value(path)} is not a directory.")
  }
}
