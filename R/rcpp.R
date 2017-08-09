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

  todo("Include the following roxygen tags somewhere in your package")
  code(
    paste0("#' @useDynLib ", project_name(base_path)),
    "#' @importFrom Rcpp sourceCpp",
    "NULL"
  )
  todo("Run document()")
}
