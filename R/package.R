#' Use specified package.
#'
#' This adds a dependency to DESCRIPTION and offers a little advice
#' about how to best use it.
#'
#' @param package Name of package to depend on.
#' @param type Type of dependency: must be one of "Imports", "Suggests",
#'   "Depends", "Suggests", "Enhances", or "LinkingTo" (or unique abbreviation)
#' @param pkg package description, can be path or package name. See
#'   \code{\link{as.package}} for more information.
#' @export
#' @examples
#' \dontrun{
#' use_package("ggplot2")
#' use_package("dplyr", "suggests")
#'
#' }
use_package <- function(package, type = "Imports", pkg = ".") {
  stopifnot(is.character(package), length(package) == 1)
  stopifnot(is.character(type), length(type) == 1)

  if (!is_installed(package)) {
    stop(package, " must be installed before you can take a dependency on it",
      call. = FALSE)
  }

  types <- c("Imports", "Depends", "Suggests", "Enhances", "LinkingTo")
  names(types) <- tolower(types)

  type <- types[[match.arg(tolower(type), names(types))]]

  message("* Adding ", package, " to ", type)
  add_desc_package(pkg, type, package)

  msg <- switch(type,
    Imports = paste0("Refer to functions with ", package, "::fun()"),
    Depends = paste0("Are you sure you want Depends? Imports is almost always",
      " the better choice."),
    Suggests = paste0("Use requireNamespace(\"", package, "\", quietly = TRUE)",
      " to test if package is installed,\n",
      "then use ", package, "::fun() to refer to functions."),
    Enhances = "",
    LinkingTo = show_includes(package)
  )
  message("Next: ")
  message(msg)
  invisible()
}

show_includes <- function(package) {
  incl <- system.file("include", package = package)
  h <- dir(incl, "\\.(h|hpp)$")
  if (length(h) == 0) return()

  message("Possible includes are:\n",
    paste0("#include <", h, ">", collapse = "\n"))

}

add_desc_package <- function(pkg = ".", field, name) {
  pkg <- as.package(pkg)
  desc_path <- file.path(pkg$path, "DESCRIPTION")

  desc <- read_dcf(desc_path)
  old <- desc[[field]]
  if (is.null(old)) {
    new <- name
    changed <- TRUE
  } else {
    if (!grepl(name, old)) {
      new <- paste0(old, ",\n    ", name)
      changed <- TRUE
    } else {
      changed <- FALSE
    }
  }
  if (changed) {
    desc[[field]] <- new
    write_dcf(desc_path, desc)
  }
  invisible(changed)
}
