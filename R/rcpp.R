#' Use Rcpp
#'
#' Creates \code{src/} and adds needed packages to \code{DESCRIPTION}.
#'
#' @inheritParams use_template
#' @export
use_rcpp <- function(base_path = ".") {
  use_dependency("Rcpp", "LinkingTo", base_path = base_path)
  use_dependency("Rcpp", "Imports", base_path = base_path)

  use_directory("src", base_path = base_path)
  use_git_ignore(c("*.o", "*.so", "*.dll"), "src", base_path = base_path)

  message(
    "Next, include the following roxygen tags somewhere in your package:\n\n",
    "#' @useDynLib ", project_name(base_path), "\n",
    "#' @importFrom Rcpp sourceCpp\n",
    "NULL\n\n",
    "Then run document()"
  )
}
