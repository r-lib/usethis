#' Use magrittr's pipe in your package
#'
#' Does setup necessary to use magrittr's pipe operator, `%>%` in your package.
#' This function requires the use roxygen.
#' * Adds magrittr to "Imports" in `DESCRIPTION`.
#' * Imports the pipe operator specifically, which is necessary for internal
#'   use.
#' * Exports the pipe operator, if `export = TRUE`, which is necessary to make
#'   `%>%` available to the users of your package.
#'
#' @param export If `TRUE`, the file `R/utils-pipe.R` is added, which provides
#' the roxygen template to import and re-export `%>%`. If `FALSE`, the necessary
#' roxygen directive is added, if possible, or otherwise instructions are given.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' use_pipe()
#' }
use_pipe <- function(export = TRUE) {
  check_is_package("use_pipe()")
  check_uses_roxygen("use_pipe()")

  if (export) {
    use_dependency("magrittr", "Imports")
    use_template("pipe.R", "R/utils-pipe.R") && roxygen_remind()
    return(invisible(TRUE))
  }

  use_import_from("magrittr", "%>%")
}
