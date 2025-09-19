#' Use magrittr's pipe in your package
#'
#' Does setup necessary to use magrittr's pipe operator, `%>%` in your package.
#' This function requires the use of \pkg{roxygen2}.
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
#'#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' The base R pipe has been available since R 4.1.0, which handles most cases
#' the `magrittr` pipe handles -- `%>%` can usually just be replaced with `|>`.
#' To read about the differences, read this `tidyverse`
#' [blog post](https://www.tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/)
#' describing some special cases where using the base R pipe requires handling
#' different from the `magrittr` pipe, including using
#' * `x |> f(1, y = _)` instead of `x %>% f(1, y = .)`,
#' * `x |> (\(x) x[[1]]))()` instead of `x %>% .[[1]]`,
#' * `x |> (\(x) f(a = x, b = x))()` instead of `x %>% f(a = ., b = .)`, and
#' * `x |> f()` instead of `x %>% f`.
#'
#' @export
#'
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' use_pipe()
#' }
use_pipe <- function(export = TRUE) {
  lifecycle::deprecate_warn(when = "3.2.2", what = "use_pipe()")

  check_is_package("use_pipe()")
  check_uses_roxygen("use_pipe()")

  if (export) {
    use_dependency("magrittr", "Imports")
    use_template("pipe.R", "R/utils-pipe.R") && roxygen_remind()
    return(invisible(TRUE))
  }

  use_import_from("magrittr", "%>%")
}
