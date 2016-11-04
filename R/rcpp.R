#' Use Rcpp
#'
#' Creates \code{src/} and adds needed packages to \code{DESCRIPTION}.
#' @export
use_rcpp <- function(base_path = ".") {
  use_dependency("Rcpp", "LinkingTo", base_path = base_path)
  use_dependency("Rcpp", "Imports", base_path = base_path)

  use_directory("src/", base_path = base_path)

  ignore_path <- file.path(pkg$path, "src", ".gitignore")
  union_write(ignore_path, c("*.o", "*.so", "*.dll"))

  message(
    "Next, include the following roxygen tags somewhere in your package:\n\n",
    "#' @useDynLib ", pkg$package, "\n",
    "#' @importFrom Rcpp sourceCpp\n",
    "NULL\n\n",
    "Then run document()"
  )
}
