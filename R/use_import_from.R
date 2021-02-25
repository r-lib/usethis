#' Import a function from another package
#'
#' `use_import_from()` adds the Roxygen tag `@importFrom` to the package-level
#' documentation (possibly created with [`use_package_doc()`]). Importing a
#' function from another package allows you to refer to it without a namespace
#' (e.g. `fun()` instead of `package::fun()`). Use such imports judiciously, as
#' they make it hard to tell where a function comes from.
#'
#' @param package Name of package to import `fun` from
#' @param fun Name of function to import
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
  no_pkg_doc <- check_has_package_doc()

  if (no_pkg_doc) {
    return(FALSE)
  }

  use_dependency(package, "Imports")
  changed <- roxygen_ns_append(import_from(package, fun)) &&
    roxygen_update()

  if (changed && load) {
    check_installed("pkgload")
    pkgload::load_all()
  }

  invisible(changed)
}

import_from <- function(package, fun) {
  fun <- gsub("\\(.*\\)", "", fun)
  glue("@importFrom {package} {fun}")
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
    return(invisible(FALSE))
  }

  invisible(TRUE)
}
