#' Create a CRAN badge
#'
#' This prints out the markdown which will display a CRAN "badge", indicating
#' what version of your package is available on CRAN, powered by
#' \url{(http://www.r-pkg.org}.
#'
#' @inheritParams use_template
#' @export
use_cran_badge <- function(base_path = ".") {
  pkg <- package_name(base_path)

  src <- paste0("http://www.r-pkg.org/badges/version/", pkg)
  href <- paste0("https://cran.r-project.org/package=", pkg)
  use_badge("CRAN status", href, src, base_path = base_path)

  invisible(TRUE)
}

use_badge <- function(badge_name, href, src, base_path = ".") {
  img <- paste0("![", badge_name, "](", src, ")")
  link <- paste0("[", img, "](", href, ")")

  message(
    " * Add a ", badge_name, " badge by adding the following line to your README:\n",
    link
  )
}
