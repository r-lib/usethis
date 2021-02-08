#' Use stopwords in your package
#'
#' Sets up your package to import and re-export the `stopwords::stopwords()`
#' function in your package. This function requires the use of the
#' \pkg{roxygen2} package.
#' * Adds `stopwords`` to "Imports" in `DESCRIPTION`.
#' * Imports `stopwords()`, which is necessary for internal use.
#' * Exports `stopwords()`, if `export = TRUE`, which is necessary to make the
#'   function available to the users of your package.
#'
#' @param export If `TRUE`, the file `R/utils-stopwords.R` is added, which
#'   provides the roxygen template to import and re-export `stopwords()`. If
#'   `FALSE`, the necessary roxygen directive is added, if possible, or
#'   otherwise instructions are given.
#' @export
#' @examples
#' \dontrun{
#' use_stopwords()
#' }
use_stopwords <- function(export = TRUE) {
  check_is_package("use_stopwords()")
  check_uses_roxygen("use_stopwords()")

  use_dependency("stopwords", "Imports")

  if (export) {
    use_template("stopwords.R", "R/utils-stopwords.R", package = "stopwords") && roxygen_update()
    return(invisible(TRUE))
  }

  if (has_package_doc()) {
    roxygen_ns_append("@importFrom stopwords stopwords") && roxygen_update()
    return(invisible(TRUE))
  }

  ui_todo(
    "Copy and paste this line into some roxygen header, then run \\
    {ui_code('devtools::document()')}:"
  )
  ui_code_block("#' @importFrom stopwords stopwords", copy = FALSE)
  ui_todo(
    "Alternative recommendation: call {ui_code('use_package_doc()')}, then \\
    call {ui_code('use_stopwords()')} again."
  )
  invisible(FALSE)
}
