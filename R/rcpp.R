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

  makevars_settings <- list(
    "CXX_STD"="CXX11",
    "PKG_CXXFLAGS"="$(SHLIB_OPENMP_CXXFLAGS)",
    "PKG_LIBS"="$(SHLIB_OPENMP_CXXFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS)"
  )
  use_makevars(makevars_settings)

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

use_makevars <- function(settings = NULL) {

  settings_list <- settings %||% list()
  check_is_named_list(settings_list)

  makevars_entries <- vapply(settings_list, glue_collapse, character(1))
  makevars_content <- glue("{names(makevars_entries)}={makevars_entries}")

  makevars_path <- proj_path("src/Makevars")
  makevars_win_path <- proj_path("src/Makevars.win")
  makevars_files <- c(makevars_path, makevars_win_path)

  if (all(!file_exists(makevars_files))) {
    for(makevars_file_path in makevars_files) {
      write_utf8(makevars_file_path, makevars_content)
      ui_done("Created {ui_path(makevars_file_path)} with requested compilation settings.")
    }
  } else {
    ui_todo("Ensure the following Makevars compilation settings are set for both \\
            {ui_path(makevars_path)} and {ui_path(makevars_win_path)}:")
    ui_code_block(
      makevars_content
    )
    edit_file(makevars_path)
    edit_file(makevars_win_path)
  }

}
