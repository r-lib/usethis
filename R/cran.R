#' Create a comment for submission to CRAN.
#'
#' This creates a template for your communications with CRAN when submitting a
#' package. The goal of the file is to clearly communicate what steps you have
#' taken to check that your package works across a wide range of operating
#' systems. If you are submitting an update to a package that is used by
#' other packages, you also need to describe the steps you have taken to
#' ensure that it does not break existing code on CRAN.
#'
#' @export
#' @inheritParams use_template
use_cran_comments <- function(open = TRUE) {
  use_template(
    "cran-comments.md",
    data = list(rversion = paste0(version$major, ".", version$minor)),
    ignore = TRUE,
    open = open
  )

  invisible(TRUE)
}

