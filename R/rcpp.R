#' Use Rcpp
#'
#' Creates `src/` and adds needed packages to `DESCRIPTION`.
#'
#' @export
use_rcpp <- function() {
  check_is_package("use_rcpp()")
  check_uses_roxygen("use_rcpp()")

  use_src()

  use_dependency("Rcpp", "LinkingTo")
  use_dependency("Rcpp", "Imports")
  roxygen_ns_append("@importFrom Rcpp sourceCpp") && roxygen_update()

  invisible()
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
