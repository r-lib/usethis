#' Prepare to return a tibble
#'
#' @description Does minimum setup such that a tibble returned by your package
#' is handled using the tibble method for generics like `print()` or \code{[}.
#' Presumably you care about this if you've chosen to store and expose an
#' object with class `tbl_df`. Specifically:
#'   * Check that the active package uses roxygen2
#'   * Add the tibble package to "Imports" in `DESCRIPTION`
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
  check_uses_roxygen("use_tibble()")

  use_dependency("tibble", "Imports")
  roxygen_ns_append("@importFrom tibble tibble") && roxygen_update()

  ui_todo("Document a returned tibble like so:")
  ui_code_block("#' @return a [tibble][tibble::tibble-package]", copy = FALSE)
}
