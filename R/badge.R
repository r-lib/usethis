#' README badges
#'
#' These helpers produce the markdown text you need in your README to include
#' badges that report information, such as the CRAN version or test coverage,
#' and link out to relevant external resources.
#'
#' @details
#'
#' * `use_badge()`: a general helper used in all badge functions
#' * `use_bioc_badge()`: badge indicates [BioConductor build
#' status](http://bioconductor.org/developers/)
#' * `use_cran_badge()`: badge indicates what version of your package is
#' available on CRAN, powered by <https://www.r-pkg.org>
#' * `use_depsy_badge()`: badge shows the "percentile overall impact" of the
#' project, powered by <http://depsy.org>, which only indexes projects that are
#' on CRAN
#' * `use_lifecycle_badge()`: badge declares the developmental stage of a
#' package, according to <https://www.tidyverse.org/lifecycle/>:
#'   - Experimental
#'   - Maturing
#'   - Stable
#'   - Retired
#'   - Archived
#'   - Dormant
#'   - Questioning
#' * `use_binder_badge()`: badge indicates that your repository can be launched
#' in an executable environment on <https://mybinder.org/>
#'
#' @param badge_name Badge name. Used in error message and alt text
#' @param href,src Badge link and image src
#' @param stage Stage of the package lifecycle
#'
#' @seealso The [functions that set up continuous integration
#'   services][use_travis] also create badges.
#'
#' @name badges
#' @examples
#' \dontrun{
#' use_cran_badge()
#' use_lifecycle_badge("stable")
#' }
NULL

#' @rdname badges
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

#' @rdname badges
#' @export
use_cran_badge <- function() {
  check_is_package("use_cran_badge()")
  pkg <- project_name()

  src <- file.path("https://www.r-pkg.org/badges/version", pkg)
  href <- paste0("https://cran.r-project.org/package=", pkg)
  use_badge("CRAN status", href, src)

  invisible(TRUE)
}

#' @rdname badges
#' @export
use_bioc_badge <- function() {
  check_is_package("use_bioc_badge()")
  pkg <- project_name()

  src <- paste0(
    "http://www.bioconductor.org/shields/build/release/bioc/",
    pkg, ".svg"
  )
  href <- file.path(
    "https://bioconductor.org/checkResults/release/bioc-LATEST",
    pkg
  )
  use_badge("BioC status", href, src)

  invisible(TRUE)
}

#' @rdname badges
#' @export
use_depsy_badge <- function() {
  check_is_package("use_depsy_badge()")
  pkg <- project_name()

  src <- file.path("http://depsy.org/api/package/cran", pkg, "badge.svg")
  href <- file.path("http://depsy.org/package/r", pkg)
  use_badge("Depsy", href, src)

  invisible(TRUE)
}

#' @rdname badges
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

#' @rdname badges
#' @export
use_binder_badge <- function() {

  if (uses_github(proj_get())) {
    gh <- gh::gh_tree_remote(proj_get())

    url <- file.path(
      "https://mybinder.org/v2/gh",
      gh$username,
      gh$repo,
      "master")

    img <- "http://mybinder.org/badge.svg"

    use_badge("Binder", url, img)
  }

  invisible(TRUE)
}



has_badge <- function(href) {
  readme_path <- proj_path("README.md")
  if (!file.exists(readme_path)) {
    return(FALSE)
  }

  readme <- readLines(readme_path)
  any(grepl(href, readme, fixed = TRUE))
}
