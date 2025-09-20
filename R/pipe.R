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
#' However, other differences include:
#' * instead of `x %>% f(1, y = .)`, use `x |> f(1, y = _)`,
#' * instead of `x %>% .[[1]]`, use `x |> (\(x) x[[1]]))()`,
#' * instead of `x %>% f(a = ., b = .)`, use `x |> (\(x) f(a = x, b = x))()`,
#'     and
#' * instead of `x %>% f`, use `x |> f()`.
#' To read about these differences, read this `tidyverse`
#' [blog post](https://www.tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/).
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
  lifecycle::deprecate_warn(
    when = "3.2.2",
    what = "usethis::use_pipe()",
    details = "It is recommended to use the base R pipe |> in your package
      instead; it does not require an import."
  )

  check_is_package("use_pipe()")
  check_uses_roxygen("use_pipe()")

  if (export) {
    use_dependency("magrittr", "Imports")
    use_template("pipe.R", "R/utils-pipe.R") && roxygen_remind()
    return(invisible(TRUE))
  }

  use_import_from("magrittr", "%>%")
}
