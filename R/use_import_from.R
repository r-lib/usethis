#' Import a function from another package
#'
#' `use_import_from()` imports a function from another package by adding the
#' roxygen2 `@importFrom` tag to the package-level documentation (which can
#' be created with [`use_package_doc()`]). Importing a function from another
#' package allows you to refer to it without a namespace (e.g., `fun()` instead
#' of `package::fun()`).
#'
#' @param package Package name
#' @param fun A vector of function names
#' @param load Logical. Re-load with [`pkgload::load_all()`]?
#'
#' @return Invisibly, `TRUE` if the package document has changed, `FALSE` if
#'   not.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' use_import_from("usethis", "ui_todo")
#' }
#'
use_import_from <- function(package, fun, load = is_interactive()) {
  check_is_package("use_import_from()")
  check_uses_roxygen("use_import_from()")

  if (!check_has_package_doc()) {
    return(invisible(FALSE))
  }

  use_dependency(package, "Imports")

  fun <- gsub("\\(.*\\)", "", fun)
  fun <- glue_collapse(fun, sep = " ")
  changed <- roxygen_ns_append(glue("@importFrom {package} {fun}")) &&
    roxygen_update_ns()

  if (changed && load) {
    check_installed("pkgload")
    pkgload::load_all()
  }

  invisible(changed)
}

check_has_package_doc <- function() {
  if (has_package_doc()) {
    return(invisible(TRUE))
  }

  if (!is_interactive()) {
    return(invisible(FALSE))
  }

  add_pkg_doc <- ui_yeah("{ui_code('use_import_from()')} requires \\
                         package-level documentation. Would you like to add \\
                         it now?")
  if (add_pkg_doc) {
    use_package_doc()
  } else {
    ui_todo("Run {ui_code('use_package_doc()')}")
    return(invisible(FALSE))
  }

  invisible(TRUE)
}
