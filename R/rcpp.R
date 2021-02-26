#' Use C, C++, RcppArmadillo, or RcppEigen
#'
#' Adds infrastructure commonly needed when using compiled code:
#'   * Creates `src/`
#'   * Adds required packages to `DESCRIPTION`
#'   * May create an initial placeholder `.c` or `.cpp` file
#'   * Creates `Makevars` and `Makevars.win` files (`use_rcpp_armadillo()` only)
#'
#' @param name If supplied, creates and opens `src/name.{c,cpp}`.
#'
#' @details
#'
#' When using compiled code, please note that there must be at least one file
#' inside the `src/` directory prior to building the package. As a result,
#' if an empty `src/` directory is detected, either a `.c` or `.cpp` file will
#' be added.
#'
#' @export
use_rcpp <- function(name = NULL) {
  check_is_package("use_rcpp()")
  check_uses_roxygen("use_rcpp()")

  use_src()

  use_dependency("Rcpp", "LinkingTo")
  use_dependency("Rcpp", "Imports")
  roxygen_ns_append("@importFrom Rcpp sourceCpp") && roxygen_remind()

  use_src_example_script(name, "cpp")

  invisible()
}

#' @rdname use_rcpp
#' @export
use_rcpp_armadillo <- function(name = NULL) {
  use_rcpp(name)

  use_dependency("RcppArmadillo", "LinkingTo")

  makevars_settings <- list(
    "CXX_STD" = "CXX11",
    "PKG_CXXFLAGS" = "$(SHLIB_OPENMP_CXXFLAGS)",
    "PKG_LIBS" = "$(SHLIB_OPENMP_CXXFLAGS) $(LAPACK_LIBS) $(BLAS_LIBS) $(FLIBS)"
  )
  use_makevars(makevars_settings)

  invisible()
}

#' @rdname use_rcpp
#' @export
use_rcpp_eigen <- function(name = NULL) {
  use_rcpp(name)

  use_dependency("RcppEigen", "LinkingTo")

  roxygen_ns_append("@import RcppEigen") && roxygen_remind()

  invisible()
}

#' @rdname use_rcpp
#' @export
use_c <- function(name = NULL) {
  check_is_package("use_c()")
  check_uses_roxygen("use_c()")

  use_src()

  use_src_example_script(name, "c")

  invisible(TRUE)
}

use_src <- function() {
  use_directory("src")
  use_git_ignore(c("*.o", "*.so", "*.dll"), "src")
  roxygen_ns_append(glue("@useDynLib {project_name()}, .registration = TRUE")) &&
    roxygen_remind()

  invisible()
}

use_makevars <- function(settings = NULL) {
  use_directory("src")

  settings_list <- settings %||% list()
  check_is_named_list(settings_list)

  makevars_entries <- vapply(settings_list, glue_collapse, character(1))
  makevars_content <- glue("{names(makevars_entries)} = {makevars_entries}")

  makevars_path <- proj_path("src", "Makevars")
  makevars_win_path <- proj_path("src", "Makevars.win")

  if (!file_exists(makevars_path) && !file_exists(makevars_win_path)) {
    write_utf8(makevars_path, makevars_content)
    file_copy(makevars_path, makevars_win_path)
    ui_done("Created {ui_path(makevars_path)} and {ui_path(makevars_win_path)} \\
             with requested compilation settings.")
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

use_src_example_script <- function(name = NULL, src_type = c("cpp", "c")) {
  src_type <- match.arg(src_type)

  if (!directory_has_files(path("src"))) {
    name <- name %||% "code"
  }

  if (!is.null(name)) {
    name <- slug(name, src_type)
    check_file_name(name)
    use_template(
      slug("code", src_type),
      path("src", name),
      open = is_interactive()
    )
  }
}
