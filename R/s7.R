#' Use S7
#'
#' Sets up a package to use [S7](https://rconsortium.github.io/S7/) classes.
#'   * Adds S7 to `Imports` in `DESCRIPTION`
#'   * Creates `R/zzz.R` with a call to `S7::methods_register()` in `.onLoad()`
#'   * Optionally adds a `@rawNamespace` directive to enable the use of
#'   `<S7_object>@name` syntax in package code for R versions prior to 4.3.0
#'   (see [Using S7 in a Package](https://rconsortium.github.io/S7/articles/packages.html))
#'
#' @param backwards_compat If `TRUE` (the default), adds a `@rawNamespace`
#'   directive to the package-level documentation that conditionally imports
#'   the `@` operator from S7 for R versions prior to 4.3.0.
#'
#' @export
#' @examples
#' \dontrun{
#' use_s7()
#' }
use_s7 <- function(backwards_compat = TRUE) {
  check_is_package("use_s7()")
  check_uses_roxygen("use_s7()")
  check_installed("S7")

  use_dependency("S7", "Imports")

  use_zzz()
  ensure_s7_methods_register()

  if (backwards_compat) {
    check_has_package_doc("use_s7()")
    changed <- roxygen_ns_append(
      '@rawNamespace if (getRversion() < "4.3.0") importFrom("S7", "@")'
    )
    if (changed) {
      roxygen_remind()
    }
  }

  ui_bullets(
    c(
      "_" = "Run {.run devtools::document()} to update {.path NAMESPACE}."
    )
  )

  invisible(TRUE)
}


use_zzz <- function() {
  check_is_package("use_zzz()")

  zzz_path <- proj_path("R", "zzz.R")

  if (file_exists(zzz_path)) {
    return(invisible(FALSE))
  }

  msg <- c(
    "!" = "{.path R/zzz.R} does not exist.",
    " " = "Would you like to create it now?"
  )

  if (is_interactive() && ui_yep(msg)) {
    use_template("zzz.R", path("R", "zzz.R"))
    return(invisible(TRUE))
  }

  ui_abort(c(
    "{.path R/zzz.R} does not exist.",
    "Create it manually or run this function interactively."
  ))
}


ensure_s7_methods_register <- function() {
  zzz_path <- proj_path("R", "zzz.R")
  lines <- read_utf8(zzz_path)

 # Check if S7::methods_register() is already present (uncommented)
  if (any(grepl("^\\s*S7::methods_register\\(\\)", lines))) {
    return(invisible(TRUE))
 }

  # If file is identical to template, overwrite with S7 enabled version
  template_lines <- render_template("zzz.R")
  if (identical(lines, template_lines)) {
    write_utf8(zzz_path, c(
      ".onLoad <- function(libname, pkgname) {",
      "  S7::methods_register()",
      "}"
    ))
    ui_bullets(c(
      "v" = "Added {.code S7::methods_register()} to {.path {pth(zzz_path)}}."
    ))
    return(invisible(TRUE))
  }

  # File has been modified - prompt user to add it manually
  ui_bullets(c(
    "_" = "Ensure {.code S7::methods_register()} is called in {.code .onLoad()}
           in {.path {pth(zzz_path)}}."
  ))
  edit_file(zzz_path)
  invisible(FALSE)
}
