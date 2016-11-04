#' Create tests
#'
#' \code{use_testthat} sets up testing infrastructure, creating
#' \file{tests/testthat.R} and \file{tests/testthat/}, and
#' adding \pkg{testthat} to the suggested packages. \code{use_test}
#' creates \file{tests/testthat/test-<name>.R} and opens it for editing.
#'
#' @export
#' @inheritParams use_template
use_testthat <- function(base_path = ".") {
  use_dependency("testthat", "Suggests", base_path = base_path)
  use_directory("tests/testthat", base_path = base_path)
  use_template(
    "testthat.R",
    "tests/testthat.R",
    data = list(name = package_name(base_path)),
    base_path = base_path
  )

  invisible(TRUE)
}

#' @rdname use_testthat
#' @export
use_test <- function(name, base_path = ".") {
  if (!uses_testthat(base_path)) {
    use_testthat(base_path)
  }

  use_template("test-example.R",
    sprintf("tests/testthat/test-%s.R", name),
    data = list(test_name = name),
    open = TRUE,
    base_path = base_path
  )

  invisible(TRUE)
}

uses_testthat <- function(base_path = ".") {
  paths <- c(
    file.path(base_path, "inst", "tests"),
    file.path(base_path, "tests", "testthat")
  )

  any(dir.exists(paths))
}
