#' Create or edit a .R file
#'
#' @param name File name, without extension; will create if it doesn't already
#'   exist. If not specified, and you're currently in a test file, will guess
#'   name based on test name.
#' @seealso [use_test()], and also the [R code
#'   chapter](https://r-pkgs.org/r.html) of [R
#'   Packages](https://r-pkgs.org).
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
    ui_stop(c(
      "{ui_value(name)} is not a valid file name. It should:",
      "* Contain only ASCII letters, numbers, '-', and '_'."
    ))
  }
  name
}

valid_file_name <- function(x) {
  grepl("^[a-zA-Z0-9._-]+$", x)
}

get_active_r_file <- function(path = "R") {
  if (!rstudioapi::isAvailable()) {
    ui_stop("Argument {ui_code('name')} must be specified.")
  }
  ## rstudioapi can return a path like '~/path/to/file' where '~' means
  ## R's notion of user's home directory
  active_file <- proj_path_prep(rstudioapi::getSourceEditorContext()$path)

  rel_path <- proj_rel_path(active_file)
  if (path_dir(rel_path) != path) {
    ui_stop(c(
      "Open file must be in the {ui_path(path)} directory of the active package.",
      "  * Actual path: {ui_path(rel_path)}"
    ))
  }

  ext <- path_ext(active_file)
  if (toupper(ext) != "R") {
    ui_stop(
      "Open file must have {ui_value('.R')} or {ui_value('.r')} as extension,\\
      not {ui_value(ext)}."
    )
  }

  path_file(active_file)
}
