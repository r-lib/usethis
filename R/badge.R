#' Create a CRAN badge
#'
#' This prints out the markdown which will display a CRAN "badge", indicating
#' what version of your package is available on CRAN, powered by
#' \url{http://www.r-pkg.org}.
#'
#' @inheritParams use_template
#' @export
use_cran_badge <- function() {
  pkg <- project_name()

  src <- paste0("http://www.r-pkg.org/badges/version/", pkg)
  href <- paste0("https://cran.r-project.org/package=", pkg)
  use_badge("CRAN status", href, src)

  invisible(TRUE)
}

#' Create a Depsy badge
#'
#' This prints out the markdown which will display a Depsy "badge", showing the
#' "percentile overall impact" of the project, powered by
#' \url{http://depsy.org}.
#'
#' Depsy only indexes projects that are on CRAN.
#'
#' @inheritParams use_template
#' @export
use_depsy_badge <- function() {
  pkg <- project_name()

  src <- paste0("http://depsy.org/api/package/cran/",pkg,"/badge.svg")
  href <- paste0("http://depsy.org/package/r/", pkg)
  use_badge("Depsy", href, src)

  invisible(TRUE)
}

#' Use a README badge
#'
#' @param badge_name Badge name. Used in error message and alt text
#' @param href,src Badge link and image src
#' @inheritParams use_template
#' @export
use_badge <- function(badge_name, href, src) {
  if (has_badge(href)) {
    return(FALSE)
  }

  img <- paste0("![", badge_name, "](", src, ")")
  link <- paste0("[", img, "](", href, ")")

  todo("Add a ", badge_name, " badge by adding the following line to your README:")
  code_block(link)
}

has_badge <- function(href) {
  readme_path <- file.path(proj_get(), "README.md")
  if (!file.exists(readme_path)) {
    return(FALSE)
  }

  readme <- readLines(readme_path)
  any(grepl(href, readme, fixed = TRUE))

}
