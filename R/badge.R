#' Create a CRAN badge
#'
#' This prints out the markdown which will display a CRAN "badge", indicating
#' what version of your package is available on CRAN, powered by
#' <https://www.r-pkg.org>.
#'
#' @export
use_cran_badge <- function() {
  check_is_package("use_cran_badge()")
  pkg <- project_name()

  src <- paste0("http://www.r-pkg.org/badges/version/", pkg)
  href <- paste0("https://cran.r-project.org/package=", pkg)
  use_badge("CRAN status", href, src)

  invisible(TRUE)
}

#' Create a Depsy badge
#'
#' This prints out the markdown which will display a Depsy "badge", showing the
#' "percentile overall impact" of the project, powered by <http://depsy.org>.
#'
#' Depsy only indexes projects that are on CRAN.
#'
#' @export
use_depsy_badge <- function() {
  check_is_package("use_depsy_badge()")
  pkg <- project_name()

  src <- paste0("http://depsy.org/api/package/cran/", pkg, "/badge.svg")
  href <- paste0("http://depsy.org/package/r/", pkg)
  use_badge("Depsy", href, src)

  invisible(TRUE)
}


#' Create a life cycle badge
#'

#' Declares the developmental stage of a package, according to
#' <https://www.tidyverse.org/lifecycle/>:
#'
#' * Experimental
#' * Maturing
#' * Stable
#' * Retired
#' * Archived
#' * Dormant
#' * Questioning
#'
#' @param stage Stage of the lifecycle. See description above.
#' @export
use_lifecycle_badge <- function(stage) {
  check_is_package("use_lifecycle_badge()")
  pkg <- project_name()

  stage <- match.arg(tolower(stage), names(stages))
  colour <- stages[[stage]]

  src <- paste0(
    "https://img.shields.io/badge/lifecycle-", stage, "-", colour, ".svg"
  )
  href <- paste0("https://www.tidyverse.org/lifecycle/#", stage)
  use_badge("lifecycle", href, src)

  invisible(TRUE)
}

stages <- c(
  experimental = "orange",
  maturing = "blue",
  stable = "brightgreen",
  retired = "orange",
  archived = "red",
  dormant = "blue",
  questioning = "blue"
)


#' Use a README badge
#'
#' @param badge_name Badge name. Used in error message and alt text
#' @param href,src Badge link and image src
#' @export
use_badge <- function(badge_name, href, src) {
  if (has_badge(href)) {
    return(invisible(FALSE))
  }

  img <- paste0("![", badge_name, "](", src, ")")
  link <- paste0("[", img, "](", href, ")")

  todo(
    "Add a ",
    badge_name,
    " badge by adding the following line to your README:"
  )
  code_block(link)
}

has_badge <- function(href) {
  readme_path <- proj_path("README.md")
  if (!file.exists(readme_path)) {
    return(FALSE)
  }

  readme <- readLines(readme_path)
  any(grepl(href, readme, fixed = TRUE))
}
