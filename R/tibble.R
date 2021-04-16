#' Prepare to return a tibble
#'
#' @description
#'
#' `r lifecycle::badge("questioning")`
#'
#' Does minimum setup such that a tibble returned by your package
#' is handled using the tibble method for generics like `print()` or \code{[}.
#' Presumably you care about this if you've chosen to store and expose an
#' object with class `tbl_df`. Specifically:
#'   * Check that the active package uses roxygen2
#'   * Add the tibble package to "Imports" in `DESCRIPTION`
#'   * Prepare the roxygen directive necessary to import at least one function
#'     from tibble:
#'     - If possible, the directive is inserted into existing package-level
#'       documentation, i.e. the roxygen snippet created by  [use_package_doc()]
#'     - Otherwise, we issue advice on where the user should add the directive
#'
#' This is necessary when your package returns a stored data object that has
#' class `tbl_df`, but the package code does not make direct use of functions
#' from the tibble package. If you do nothing, the tibble namespace is not
#' necessarily loaded and your tibble may therefore be printed and subsetted
#' like a base `data.frame`.
#'
#' @export
#' @examples
#' \dontrun{
#' use_tibble()
#' }
use_tibble <- function() {
  check_is_package("use_tibble()")
  check_uses_roxygen("use_tibble()")

  created <- use_import_from("tibble", "tibble")

  ui_todo("Document a returned tibble like so:")
  ui_code_block("#' @return a [tibble][tibble::tibble-package]", copy = FALSE)

  invisible(created)
}
