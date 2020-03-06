#' Use the tidy eval data pronoun in your package
#'
#' Does setup necessary to use rlang's `.data` pronoun in your package. See [rlang::.data] for more.
#' This function requires the use roxygen.
#' * Adds rlang to "Imports" in `DESCRIPTION`.
#' * Imports the `.data` object specifically, which is necessary for internal
#'   use.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' use_data_pronoun()
#' }
use_data_pronoun <- function() {
  check_is_package("use_data_pronoun()")
  check_uses_roxygen("use_data_pronoun()")

  use_dependency("rlang", "Imports", min_version = "0.1.2")

  if (has_package_doc()) {
    roxygen_ns_append("@importFrom rlang .data") && roxygen_update()
    return(invisible(TRUE))
  }

  ui_todo(
    "Copy and paste this line into some roxygen header, then run \\
    {ui_code('devtools::document()')}:"
  )
  ui_code_block("#' @importFrom rlang .data", copy = FALSE)
  ui_todo(
    "Alternative recommendation: call {ui_code('use_package_doc()')}, then \\
    call {ui_code('use_data_pronoun()')} again."
  )
  invisible(FALSE)
}
