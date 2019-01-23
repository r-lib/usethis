#' Use magrittr's pipe in your package
#'
#' Does setup necessary to use magrittr's pipe internally in your package and to
#' re-export it for users of your package:
#' * Adds magrittr to "Imports" in `DESCRIPTION`
#' * Creates `R/utils-pipe.R` with the necessary roxygen template
#'
#' @export
use_pipe <- function() {
  check_is_package("use_pipe()")
  if (!uses_roxygen()) {
    ui_stop("{ui_code('use_pipe()')} requires that you use roxygen.")
  }

  use_dependency("magrittr", "Imports")
  new <- use_template("pipe.R", "R/utils-pipe.R")
  ui_todo("Run {ui_code('devtools::document()')}")
  invisible(new)
}
