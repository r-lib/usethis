#' Use C, C++, RcppArmadillo, or RcppEigen.
#'
#' Creates `src/`, adds required packages to `DESCRIPTION`,
#' optionally creates `.c` or `.cpp` files
#' as well as `Makevars` and `Makevars.win` files.
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
use_rcpp_armadillo <- function(name = NULL) {
  use_rcpp(name)

  use_dependency("RcppArmadillo", "LinkingTo")

  makevars_path <- proj_path("src/Makevars")
  makevars_win_path <- proj_path("src/Makevars.win")

  makevars_settings <- c(
    "CXX_STD = CXX11",
    "PKG_CXXFLAGS = $(SHLIB_OPENMP_CXXFLAGS)",
    "PKG_LIBS = $(SHLIB_OPENMP_CXXFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS)"
  )

  create_makevars(makevars_path, "RcppArmadillo", makevars_settings)
  create_makevars(makevars_win_path, "RcppArmadillo", makevars_settings)

  invisible()
}

#' @rdname use_rcpp
#' @export
use_rcpp_eigen <- function(name = NULL) {
  use_rcpp(name)

  use_dependency("RcppEigen", "LinkingTo")
  use_dependency("RcppEigen", "Imports")

  roxygen_ns_append("@import RcppEigen") && roxygen_update()

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

create_makevars <- function(path, package, settings = NULL) {

  if (!is.null(settings)) {
    makevars_settings <- paste0(settings, collapse = "\n")
  } else {
    makevars_settings <- c("# For help writing Makevars{.win}, please see",
                           "# Writing R Extensions' Section 1.2.1: Using Makevars.")
  }

  if (!file_exists(path)) {
    write_utf8(path, makevars_settings)
    ui_done("Added {ui_value(package)} settings to {ui_path(path)}.")
  } else {
    ui_todo("Ensure the Makevars settings required by {ui_value(package)} are found in {ui_path(path)}.")
    ui_code_block(
      makevars_settings
    )
    edit_file(path)
  }

}
