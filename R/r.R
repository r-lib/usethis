#' Create a new R file
#'
#' @param name File name, without extension; will create if it doesn't already
#'   exist. If not specified, and you're currently in a test file, will guess
#'   name based on test name.
#' @seealso [use_test()]
#' @export
use_r <- function(name = NULL) {
  name <- name %||% get_active_r_file(path = "tests/testthat")
  name <- gsub("^test-", "", name)
  name <- slug(name, "R")
  check_file_name(name)

  use_directory("R")
  edit_file(proj_path("R", name))

  invisible(TRUE)
}

check_file_name <- function(name) {
  if (!valid_file_name(path_ext_remove(name))) {
    stop_glue(
      "{value(name)} is not a valid file name. It should:\n",
      "* Contain only ASCII letters, numbers, '-', and '_'\n"
    )
  }
  name
}

valid_file_name <- function(x) {
  grepl("^[[:alnum:]_-]+$", x)
}

get_active_r_file <- function(path = "R") {
  if (!rstudioapi::isAvailable()) {
    stop_glue("Argument {code('name')} must be specified.")
  }
  ## rstudioapi can return a path like '~/path/to/file' where '~' means
  ## R's notion of user's home directory
  active_file <- path_expand_r(rstudioapi::getSourceEditorContext()$path)

  rel_path <- proj_rel_path(active_file)
  if (path_dir(rel_path) != path) {
    stop_glue(
      "Open file must be in the {value(path, '/')} directory of ",
      "the active package.\n",
      "  * Actual path: {value(rel_path)}"
    )
  }

  ext <- path_ext(active_file)
  if (toupper(ext) != "R") {
    stop_glue(
      "Open file must have {value('.R')} or {value('.r')} as extension, ",
      "not {value(ext)}."
    )
  }

  path_file(active_file)
}
