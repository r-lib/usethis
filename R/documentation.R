#' Package-level documentation
#'
#' Adds a dummy `.R` file that will cause roxygen2 to generate basic
#' package-level documentation. If your package is named "foo", this will make
#' help available to the user via `?foo` or `package?foo`. Once you call
#' `devtools::document()`, roxygen2 will flesh out the `.Rd` file using data
#' from the `DESCRIPTION`. That ensures you don't need to repeat (and remember
#' to update!) the same information in multiple places. This `.R` file is also a
#' good place for roxygen directives that apply to the whole package (vs. a
#' specific function), such as global namespace tags like `@importFrom`.
#'
#' There is one tricky case: when a **package** named "foo" also has a
#' **function** named `foo()`. In this case, after running `use_package_doc()`,
#' there will be an `R CMD check` warning. The solution is to set the `@aliases`
#' for the package-level help topic by modifying the dummy `.R` file (e.g.,
#' `foo-package.R`) as shown below (but substitute the name of your package /
#' function for "foo"):
#'
#' ```
#' #' @keywords internal
#' #' @aliases foo-package
#' #' "_PACKAGE"
#' ```
#' @seealso The [documentation chapter](https://r-pkgs.org/man.html) of [R
#'   Packages](https://r-pkgs.org)
#' @inheritParams use_template
#' @export
use_package_doc <- function(open = rlang::is_interactive()) {
  check_is_package("use_package_doc()")
  use_template(
    "packagename-package.R",
    package_doc_path(),
    open = open
  )
}

package_doc_path <- function() {
  path("R", paste0(project_name(), "-package"), ext = "R")
}

has_package_doc <- function() {
  file_exists(proj_path(package_doc_path()))
}
