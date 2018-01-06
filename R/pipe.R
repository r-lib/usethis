#' Use magrittr's pipe in your package
#'
#' Does setup necessary to use magrittr's pipe internally in your package and to
#' re-export it for users of your package:
#' * Adds magrittr to "Imports" in DESCRIPTION
#' * Creates `R/utils-pipe.R` with the necessary roxygen template
#'
#' @export
use_pipe <- function() {
  check_is_package("use_pipe()")
  if (!uses_roxygen()) {
    stop(code("use_pipe()"), " requires that you use roxygen", call. = FALSE)
  }

  use_dependency("magrittr", "Imports")
  use_template("pipe.R", "R/utils-pipe.R")

  todo("Run ", code("document()"))
}
