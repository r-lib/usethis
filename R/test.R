#' Create tests
#'
#' `use_testthat()` sets up testing infrastructure, creating
#' \file{tests/testthat.R} and \file{tests/testthat/}, and
#' adding \pkg{testthat} to the suggested packages. `use_test()`
#' creates \file{tests/testthat/test-<name>.R} and opens it for editing.
#'
#' @export
#' @inheritParams use_template
use_testthat <- function() {
  check_is_package("use_testthat()")
  check_installed("testthat")

  use_dependency("testthat", "Suggests")
  use_directory("tests/testthat")
  use_template(
    "testthat.R",
    "tests/testthat.R",
    data = list(name = project_name())
  )

  invisible(TRUE)
}

#' @rdname use_testthat
#' @param name Test name. if `NULL`, and you're using RStudio, will use
#'   the name of the file open in the source editor.
#' @export
use_test <- function(name = NULL, open = interactive()) {
  name <- name %||% get_active_r_file(path = "R")
  name <- paste0("test-", name)
  name <- slug(name, "R")

  if (!uses_testthat()) {
    use_testthat()
  }

  path <- path("tests", "testthat", name)

  if (file_exists(proj_path(path))) {
    if (open) {
      edit_file(proj_path(path))
    }
  } else {
    use_template(
      "test-example.R",
      path,
      data = list(test_name = path_ext_remove(name)),
      open = open
    )
  }

  invisible(TRUE)
}

uses_testthat <- function(base_path = proj_get()) {
  paths <- c(
    path(base_path, "inst", "tests"),
    path(base_path, "tests", "testthat")
  )

  any(dir_exists(paths))
}
