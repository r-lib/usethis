#' Use Rcpp
#'
#' Creates `src/` and adds needed packages to `DESCRIPTION`.
#'
#' @inheritParams use_template
#' @export
use_rcpp <- function(base_path = ".") {
  use_dependency("Rcpp", "LinkingTo", base_path = base_path)
  use_dependency("Rcpp", "Imports", base_path = base_path)

  use_directory("src", base_path = base_path)
  use_git_ignore(c("*.o", "*.so", "*.dll"), "src", base_path = base_path)

  if (uses_roxygen(base_path)) {
    todo("Include the following roxygen tags somewhere in your package")
    code_block(
      paste0("#' @useDynLib ", project_name(base_path), ", .registration = TRUE"),
      "#' @importFrom Rcpp sourceCpp",
      "NULL"
    )
  } else {
    todo("Include the following directives in your NAMESPACE")
    code_block(
      paste0("useDynLib('", project_name(base_path), "', .registration = TRUE)"),
      "importFrom('Rcpp', 'sourceCpp')"
    )
    edit_file("NAMESPACE", base_path = base_path)

  }
  todo("Run document()")
}
