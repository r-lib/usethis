#' Import a function from another package
#'
#' @description
#' `use_import_from()` imports a function from another package by adding the
#' roxygen2 `@importFrom` tag to the package-level documentation (which can be
#' created with [`use_package_doc()`]). Importing a function from another
#' package allows you to refer to it without a namespace (e.g., `fun()` instead
#' of `package::fun()`).
#'
#' `use_import_from()` also re-documents the NAMESPACE, and re-load the current
#' package. This ensures that `fun` is immediately available in your development
#' session.
#'
#' @param package Package name
#' @param fun A vector of function names
#' @param load Logical. Re-load with [`pkgload::load_all()`]?
#' @return
#' Invisibly, `TRUE` if the package document has changed, `FALSE` if not.
#' @export
#' @examples
#' \dontrun{
#' use_import_from("usethis", "ui_todo")
#' }
use_import_from <- function(package, fun, load = is_interactive()) {
  if (!is_string(package)) {
    ui_stop("{ui_code('package')} must be a single string")
  }
  check_is_package("use_import_from()")
  check_uses_roxygen("use_import_from()")
  check_installed(package)
  check_has_package_doc("use_import_from()")
  check_functions_exist(package, fun)

  use_dependency(package, "Imports")
  changed <- roxygen_ns_append(glue("@importFrom {package} {fun}"))

  if (changed) {
    roxygen_update_ns(load)
  }

  invisible(changed)
}

check_functions_exist <- function(package, fun) {
  purrr::walk2(package, fun, check_fun_exists)
}

check_fun_exists <- function(package, fun) {
  if (exists(fun, envir = asNamespace(package))) {
    return()
  }
  name <- paste0(package, "::", fun, "()")
  ui_stop("Can't find {ui_code(name)}")
}

check_has_package_doc <- function(whos_asking) {
  if (has_package_doc()) {
    return(invisible(TRUE))
  }

  msg <- c(
    "{ui_code(whos_asking)} requires package-level documentation.",
    "Would you like to add it now?"
  )
  if (is_interactive() && ui_yeah(msg)) {
    use_package_doc()
  } else {
    ui_stop(c(
      "{ui_code(whos_asking)} requires package docs",
      "You can add it by running {ui_code('use_package_doc()')}"
    ))
  }

  invisible(TRUE)
}
