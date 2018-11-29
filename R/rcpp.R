#' Use C and C++.
#'
#' Creates `src/` and adds needed packages to `DESCRIPTION`, and
#' optionally creates `.c` or `.cpp` file.
#'
#' @param name If supplied, creates and opens `src/name.{c,cpp}`.
#' @export
use_rcpp <- function(name = NULL) {
  check_is_package("use_rcpp()")
  check_uses_roxygen("use_rcpp()")

  use_src()

  use_dependency("Rcpp", "LinkingTo")
  use_dependency("Rcpp", "Imports")
  roxygen_ns_append("@importFrom Rcpp sourceCpp") && roxygen_update()

  if (!is.null(name)) {
    name <- slug(name, "cpp")
    check_file_name(name)

    use_template("code.cpp", path("src", name), open = TRUE)
  }

  invisible()
}

#' @rdname use_rcpp
#' @export
use_c <- function(name = NULL) {
  use_src()

  if (!is.null(name)) {
    name <- slug(name, "c")
    check_file_name(name)

    use_template("code.c", path("src", name), open = TRUE)
  }

  invisible(TRUE)
}

use_src <- function() {
  check_is_package("use_src()")
  check_uses_roxygen("use_rcpp()")

  use_directory("src")
  use_git_ignore(c("*.o", "*.so", "*.dll"), "src")
  roxygen_ns_append(glue("@useDynLib {project_name()}, .registration = TRUE")) &&
    roxygen_update()

  invisible()
}
