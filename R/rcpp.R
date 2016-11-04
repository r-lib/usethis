#' Use Rcpp
#'
#' Creates \code{src/} and adds needed packages to \code{DESCRIPTION}.
#' @export
#' @rdname infrastructure
use_rcpp <- function(pkg = ".") {
  pkg <- as.package(pkg)
  check_suggested("Rcpp")

  message("Adding Rcpp to LinkingTo and Imports")
  add_desc_package(pkg, "LinkingTo", "Rcpp")
  add_desc_package(pkg, "Imports", "Rcpp")

  use_directory("src/", pkg = pkg)

  message("* Ignoring generated binary files.")
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
