#' Use magrittr's pipe in your package
#'
#' This imports magrittr, and creates a \code{R/utils-pipe.R} with the necessary
#' roxygen template to import and re-export the pipe.
#'
#' @inheritParams use_template
#' @export
use_pipe <- function(base_path = ".") {
  if (!uses_roxygen(base_path)) {
    stop("`use_pipe()` requires that you use roxygen.", call. = FALSE)
  }

  use_dependency("magrittr", "Imports", base_path = base_path)
  use_template(
    "pipe.R",
    "R/utils-pipe.R",
    base_path = base_path
  )

  todo("Run document()")

}
