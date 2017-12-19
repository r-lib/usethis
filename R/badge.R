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


#' Create a life cycle badge
#'
#' * Experimental: very early days, a lot of churn in search of a good API.
#'   Not on CRAN. Might not go anywhere. Use with care.
#' * Maturing: API roughed out, but finer details likely to change. Will strive
#'   to maintain backward compatibility, but need wider usage in order to get
#'   more feedback.
#' * Dormant: not currently working on it, but plan to come back to in the
#'   future.
#' * Stable: we're happy with the API, and the unlikely to be major changes.
#'   Backward incompatible changes will only be made if absolutely critical, and
#'   will be accompanied by a change in the major version.
#' * Questioning: no long convinced this is a good approach, but don't yet
#'   know what a better approach might be.
#' * Retired: known better replacement available elsewhere. Will remain
#'   available on CRAN.
#' * Archived: development complete. Archived on CRAN and on GitHub.
#'
#' @param stage Stage of the lifecycle. See description above.
#' @export
use_lifecycle_badge <- function(stage) {

  stage <- match.arg(tolower(stage), names(stages))
  colour <- stages[[stage]]

  url <- paste0(
    "https://img.shields.io/badge/lifecycle-", stage, "-", colour, ".svg"
  )

  use_badge("lifecycle", url, url)
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
#' @inheritParams use_template
#' @export
use_badge <- function(badge_name, href, src) {
  if (has_badge(href)) {
    return(invisible(FALSE))
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
