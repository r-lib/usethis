#' @section \code{use_testthat}:
#' Add testing infrastructure to a package that does not already have it.
#' This will create \file{tests/testthat.R}, \file{tests/testthat/} and
#' add \pkg{testthat} to the suggested packages. This is called
#' automatically from \code{\link{test}} if needed.
#' @rdname infrastructure
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

#' @section \code{use_test}:
#' Add a test file, also add testing infrastructure if necessary.
#' This will create \file{tests/testthat/test-<name>.R} with a user-specified
#' name for the test.  Will fail if the file exists.
#' @rdname infrastructure
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
