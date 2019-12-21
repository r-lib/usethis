#' Use usethis'ui(s) in your package
#'
#' Does setup necessary to use the usethis' user interfaces in your package.
#' This function requires the use roxygen.
#' * Check that the active package uses roxygen2
#' * Adds usethis package to "Imports" in `DESCRIPTION`
#' * Imports in your namespace:
#'   - block styles: \code{\link{ui_line}}, \code{\link{ui_todo}}
#'       \code{\link{ui_done}}, \code{\link{ui_todo}}, \code{\link{ui_oops}}
#'       \code{\link{ui_info}}, \code{\link{ui_code_block}}
#'   - conditions: \code{\link{ui_stop}}, \code{\link{ui_warn}}
#'   - questions: \code{\link{ui_yeah}}, \code{\link{ui_nope}}
#'   - inline styles: \code{\link{ui_field}}, \code{\link{ui_value}}
#'       \code{\link{ui_path}}, \code{\link{ui_code}}) user interfaces
#'
#' @export
#'
#' @examples
#' \dontrun{
#' use_ui()
#' }
use_ui <- function() {
  check_is_package("use_ui()")
  check_uses_roxygen("use_ui()")

  use_dependency("usethis", "Imports")

  # Paste is needed because rexygen2 reads those lines as roxygen-comments!
  # this way they start with '"' and the problem is avoided.
  roxygen_ns_append(paste(
    # The first roxygen comment tag is added by `roxygen_ns_append()` itself
    "@importFrom usethis ui_line ui_todo ui_done ui_todo ui_oops ui_info",
    "#' @importFrom usethis ui_code_block",
    "#' @importFrom usethis ui_stop ui_warn",
    "#' @importFrom usethis ui_yeah ui_nope",
    "#' @importFrom usethis ui_field ui_value ui_path ui_code",
    sep = "\n"
  )) && roxygen_update()
}
