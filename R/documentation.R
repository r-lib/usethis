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
#' @seealso The [documentation chapter](http://r-pkgs.had.co.nz/man.html) of [R
#'   Packages](http://r-pkgs.had.co.nz)
#'
#' @export
use_package_doc <- function() {
  check_is_package("use_package_doc()")
  name <- project_name()

  use_template(
    "packagename-package.R",
    path("R", paste0(name, "-package"), ext = "R"),
    data = list(name = name)
  )
}
