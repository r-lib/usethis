#' @rdname infrastructure
#' @section \code{use_cran_comments}:
#' Add \code{cran-comments.md} template.
#' @export
#' @aliases add_travis
use_cran_comments <- function(pkg = ".") {
  pkg <- as.package(pkg)

  use_template(
    "cran-comments.md",
    data = list(rversion = paste0(version$major, ".", version$minor)),
    ignore = TRUE,
    open = TRUE,
    pkg = pkg
  )

  invisible()
}

#' @rdname infrastructure
#' @section \code{use_cran_badge}:
#' Add a badge to show CRAN status and version number on the README
#' @export
use_cran_badge <- function(pkg = ".") {
  pkg <- as.package(pkg)
  message(
    " * Add a CRAN status shield by adding the following line to your README:\n",
    "[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/", pkg$package, ")](https://cran.r-project.org/package=", pkg$package, ")"
  )
  invisible(TRUE)
}
