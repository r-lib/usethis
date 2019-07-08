#' Create or edit files
#'
#' There are two functions:
#' * `use_r()` creates `<name>.R` file in the `R` directory.
#' * `use_test()` sets up individual test files: creates `tests/testthat/test-<name>.R` and, optionally, opens it for editing.
#'
#' @param name
#' * for `use_r()`: File name, without extension; will create if it doesn't already
#'   exist. If not specified, and you're currently in a test file, will guess
#'   name based on test name.
#' * for `use_test()`: Base of test file name. If `NULL`, and you're using RStudio, will
#'   be based on the name of the file open in the source editor.
#' @param open
#' * If TRUE, opens the file for editing. Defaults to return value of `interactive()`.
#' @seealso [use_testthat()] to set up the testing infrastructure. The [testing](https://r-pkgs.org/tests.html)
#' and [R code](https://r-pkgs.org/r.html) chapters of [R Packages](https://r-pkgs.org).
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
