#' Add testing infrastructor
#'
#' \code{use_testthat} sets up testing infrastructure, creating
#' \file{tests/testthat.R} and \file{tests/testthat/}, and
#' adding \pkg{testthat} to the suggested packages. \code{use_test}
#' creates \file{tests/testthat/test-<name>.R} and opens it for editing.
#'
#' @export
use_testthat <- function(pkg = ".") {
  pkg <- as.package(pkg)

  check_suggested("testthat")
  if (uses_testthat(pkg = pkg)) {
    message("* testthat is already initialized")
    return(invisible(TRUE))
  }

  message("* Adding testthat to Suggests")
  add_desc_package(pkg, "Suggests", "testthat")

  use_directory("tests/testthat", pkg = pkg)
  use_template(
    "testthat.R",
    "tests/testthat.R",
    data = list(name = pkg$package),
    pkg = pkg
  )

  invisible(TRUE)
}

#' @rdname use_testthat
#' @export
use_test <- function(name, pkg = ".") {
  pkg <- as.package(pkg)

  check_suggested("testthat")
  if (!uses_testthat(pkg = pkg)) {
    use_testthat(pkg = pkg)
  }

  use_template("test-example.R",
    sprintf("tests/testthat/test-%s.R", name),
    data = list(test_name = name),
    open = TRUE,
    pkg = pkg
  )

  invisible(TRUE)
}
