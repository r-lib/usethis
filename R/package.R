#' Use specified package.
#'
#' This adds a dependency to DESCRIPTION and offers a little advice
#' about how to best use it.
#'
#' @param package Name of package to depend on.
#' @param type Type of dependency: must be one of "Imports", "Suggests",
#'   "Depends", "Suggests", "Enhances", or "LinkingTo" (or unique abbreviation)
#' @inheritParams use_template
#' @export
#' @examples
#' \dontrun{
#' use_package("ggplot2")
#' use_package("dplyr", "suggests")
#' }
use_package <- function(package, type = "Imports", base_path = ".") {
  use_dependency(package, type, base_path = base_path)

  message("Next: ")
  switch(type,
    Imports = message("Refer to functions with ", package, "::fun()"),
    Depends = message("Are you sure you want Depends? Imports is almost always",
      " the better choice."),
    Suggests = message("Use requireNamespace(\"", package, "\", quietly = TRUE)",
      " to test if package is installed,\n",
      "then use ", package, "::fun() to refer to functions."),
    Enhances = "",
    LinkingTo = show_includes(package)
  )

  invisible()
}

show_includes <- function(package) {
  incl <- system.file("include", package = package)
  h <- dir(incl, "\\.(h|hpp)$")
  if (length(h) == 0) return()

  message("Possible includes are:\n",
    paste0("#include <", h, ">", collapse = "\n"))
}
