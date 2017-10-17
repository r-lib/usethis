#' Use magrittr's pipe in your package
#'
#' This imports magrittr, and creates a `R/utils-pipe.R` with the necessary
#' roxygen template to import and re-export the pipe.
#'
#' @inheritParams use_template
#' @export
use_pipe <- function() {
  if (!uses_roxygen()) {
    stop("`use_pipe()` requires that you use roxygen.", call. = FALSE)
  }

  use_dependency("magrittr", "Imports")
  use_template("pipe.R", "R/utils-pipe.R")

  todo("Run document()")
}
