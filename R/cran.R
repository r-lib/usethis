#' CRAN submission comments
#'
#' Creates `cran-comments.md`, a template for your communications with CRAN when
#' submitting a package. The goal is to clearly communicate the steps you have
#' taken to check your package on a wide range of operating systems. If you are
#' submitting an update to a package that is used by other packages, you also
#' need to summarize the results of your [reverse dependency
#' checks][use_revdep].
#'
#' @export
#' @inheritParams use_template
use_cran_comments <- function(open = rlang::is_interactive()) {
  check_is_package("use_cran_comments()")
  use_template(
    "cran-comments.md",
    data = list(rversion = glue("{version$major}.{version$minor}")),
    ignore = TRUE,
    open = open
  )
}
