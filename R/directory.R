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
  if (!file_exists(proj_path(path))) {
    done("Creating {value(path, '/')}")
  }
  create_directory(proj_get(), path)

  if (ignore) {
    use_build_ignore(path)
  }

  invisible(TRUE)
}

create_directory <- function(base_path, path) {
  if (!file_exists(base_path)) {
    stop_glue("{value(base_path)} does not exist.")
  }

  if (!is_dir(base_path)) {
    stop_glue("{value(base_path)} is not a directory.")
  }

  target_path <- path(base_path, path)

  if (!file_exists(target_path)) {
    dir_create(target_path, recursive = TRUE)
  }

  if (!is_dir(target_path)) {
    stop_glue("{value(path)} exists but is not a directory.")
  }

  target_path
}
