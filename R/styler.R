#' Style according to the tidyverse style guide
#'
#' Styles the source code of the package according to the
#' [tidyverse style guide](http://style.tidyverse.org).
#' @param strict Boolean indicating whether or not a strict version of styling
#'   should be applied. See [styler::tidyverse_style()] for details.
#' @section Warning:
#' This function overwrites files (if styling results in a change of the
#' code to be formatted). It is strongly suggested to only style files
#' that are under version control or to create a backup copy.
#' @return
#' Invisibly returns a data frame that indicates for each file considered for
#' styling whether or not it was actually changed.
#' @importFrom styler style_pkg
#' @importFrom styler tidyverse_style
#' @export
use_tidy_style <- function(strict = TRUE) {
  check_installed("styler")
  styled <- style_pkg(proj_get(), style = tidyverse_style, strict = strict)
  cat_line()
  done("Styled package according to the tidyverse style guide")
  invisible(styled)
}
