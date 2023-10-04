#' Package-level documentation
#'
#' Adds a dummy `.R` file that will prompt roxygen to generate basic
#' package-level documentation. If your package is named "foo", this will make
#' help available to the user via `?foo` or `package?foo`. Once you call
#' `devtools::document()`, roxygen will flesh out the `.Rd` file using data from
#' the `DESCRIPTION`. That ensures you don't need to repeat the same information
#' in multiple places. This `.R` file is also a good place for roxygen
#' directives that apply to the whole package (vs. a specific function), such as
#' global namespace tags like `@importFrom`.
#'
#' @seealso The [documentation chapter](https://r-pkgs.org/man.html) of [R
#'   Packages](https://r-pkgs.org)
#' @inheritParams use_template
#' @export
#' @details
#' use_package_doc() leads to an R-CMD-CHECK warning if package shares name with a
#' function ([Github Issue](https://github.com/r-lib/usethis/issues/1170)). This can be
#' obviated by including the following lines at the top of your mypackagename-package.R script:
#'
#' `@keywords internal`
#'
#' `@aliases reprex-package`
#'
#' `"_PACKAGE"`
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
