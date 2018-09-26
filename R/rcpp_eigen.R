#' Use RcppEigen
#'
#' Creates `src/` and adds needed packages to `DESCRIPTION`.
#'
#' @export
use_rcpp_eigen <- function() {

  check_is_package("use_rcpp_eigen()")

  use_dependency("Rcpp", "LinkingTo")
  use_dependency("Rcpp", "Imports")
  use_dependency("RcppEigen", "LinkingTo")
  use_dependency("RcppEigen", "Imports")

  use_directory("src")
  use_git_ignore(c("*.o", "*.so", "*.dll"), "src")

  if (uses_roxygen()) {
    todo("Include the following roxygen tags somewhere in your package")
    code_block(
      "#' @useDynLib {project_name()}, .registration = TRUE",
      "#' @importFrom Rcpp sourceCpp",
      "#' @import RcppEigen",
      "NULL"
    )
  } else {
    todo("Include the following directives in your NAMESPACE")
    code_block(
      "useDynLib('{project_name()}', .registration = TRUE)",
      "importFrom('Rcpp', 'sourceCpp')",
      "import('RcppEigen')"
    )
    edit_file(proj_path("NAMESPACE"))
  }

  todo("Run {code('devtools::document()')}")
}
