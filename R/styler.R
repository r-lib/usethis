#' Style according to the tidyverse style guide
#'
#' Styles the source code of a package, project or directory according to the
#' [tidyverse style guide](http://style.tidyverse.org) with the
#' package [styler](http://styler.r-lib.org).
#' @param strict Boolean indicating whether or not a strict version of styling
#'   should be applied. See [styler::tidyverse_style()] for details.
#' @section Warning:
#' This function overwrites files (if styling results in a change of the
#' code to be formatted). It is strongly suggested to only style files
#' that are under version control or to create a backup copy.
#' @return
#' Invisibly returns a data frame that indicates for each file considered for
#' styling whether or not it was actually changed.
#' @export
use_tidy_style <- function(strict = TRUE) {
  check_installed("styler")
  check_uncommitted_changes()
  if (is_package()) {
    styled <- styler::style_pkg(proj_get(),
      style = styler::tidyverse_style, strict = strict
    )
  } else {
    styled <- styler::style_dir(proj_get(),
      style = styler::tidyverse_style, strict = strict
    )
  }
  cat_line()
  done("Styled package according to the tidyverse style guide")
  invisible(styled)
}
