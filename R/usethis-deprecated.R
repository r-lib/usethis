#' Deprecated tidyverse functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' * `use_tidy_style()` is deprecated because tidyverse packages are moving
#'   towards the use of [Air](https://posit-dev.github.io/air/) for formatting.
#'   See [use_air()] for how to start using Air. To continue using the styler
#'   package, see `styler::style_pkg()` and `styler::style_dir()`.
#'
#' @keywords internal
#' @name tidy-deprecated
NULL

#' @export
#' @rdname tidy-deprecated
use_tidy_style <- function(strict = TRUE) {
  lifecycle::deprecate_warn(
    when = "3.2.0",
    what = "use_tidy_style()",
    with = "use_air()",
    details = glue(
      "
      To continue using the styler package, call `styler::style_pkg()` or `styler::style_dir()` directly."
    )
  )
}
