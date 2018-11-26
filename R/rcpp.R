#' Use Rcpp
#'
#' Creates `src/` and adds needed packages to `DESCRIPTION`.
#'
#' @export
use_rcpp <- function() {
  check_is_package("use_rcpp()")
  use_dependency("Rcpp", "LinkingTo")
  use_dependency("Rcpp", "Imports")

  use_src()
  use_namespace_line(
    "importFrom(Rcpp,sourceCpp)",
    "@importFrom Rcpp sourceCpp"
  )

  invisible()
}

use_src <- function() {
  check_is_package("use_src()")

  use_directory("src")
  use_git_ignore(c("*.o", "*.so", "*.dll"), "src")
  use_namespace_line(
    glue("useDynLib({project_name()}, .registration = TRUE)"),
    glue("@useDynLib {project_name()}, .registration = TRUE")
  )

  invisible()
}
