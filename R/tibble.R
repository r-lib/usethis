#' Prepare to return a tibble
#'
#' @description Does minimum setup such that a tibble returned by your package
#' is handled using the tibble method for generics like `print()` or \code{[}.
#' Presumably you care about this if you've chosen to store and expose an
#' object with class `tbl_df`. Specifically:
#'   * Check that the active package uses roxygen2
#'   * Add the tibble package to "Imports" in DESCRIPTION
#'   * Reveal the roxygen directive necessary to import at least one function
#'     from tibble.
#'   * Offer support re: where to put this directive. Preferred location is
#'     in the roxygen snippet produced by [use_package_doc()].
#'
#' @description This is necessary when your package returns a stored data object
#'   that has class `tbl_df`, but the package code does not make direct use of
#'   functions from the tibble package. If you do nothing, the tibble namespace
#'   is not necessarily loaded and your tibble may therefore be printed and
#'   subsetted like a base `data.frame`.
#'
#' @export
#' @examples
#' \dontrun{
#' use_tibble()
#' }
use_tibble <- function() {
  check_is_package("use_tibble()")
  if (!uses_roxygen()) {
    stop_glue("{code('use_tibble()')} requires that you use roxygen.")
  }

  use_dependency("tibble", "Imports")

  directive <- "#' @importFrom tibble tibble"
  package_doc <- proj_path("R", paste0(project_name(), "-package"), ext = "R")
  if (file_exists(package_doc)) {
    todo(
      "Add this to the roxygen header for package-level docs in ",
      "{value(proj_rel_path(package_doc))}:"
    )
    code_block(directive)
    edit_file(package_doc)
  } else {
    todo(
      "Consider calling {code('use_package_doc()')} to initialize ",
      "docs, which is a good place to put the roxygen directive below."
    )
    todo("Add this line to a relevant roxygen header:")
    code_block(directive)
  }

  todo("Run {code('devtools::document()')} to update {value('NAMESPACE')}")
  todo("Document a returned tibble like so:")
  code_block("#' @return a [tibble][tibble::tibble-package]", copy = FALSE)
}
