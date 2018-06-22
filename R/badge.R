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

  img <- glue("![{badge_name}]({src})")
  link <- glue("[{img}]({href})")

  todo(
    "Add a {field(badge_name)} badge by adding the following line ",
    "to your README:"
  )
  code_block(link)
}

#' @rdname badges
#' @export
use_cran_badge <- function() {
  check_is_package("use_cran_badge()")
  pkg <- project_name()

  src <- glue("https://www.r-pkg.org/badges/version/{pkg}")
  href <- glue("https://cran.r-project.org/package={pkg}")
  use_badge("CRAN status", href, src)

  invisible(TRUE)
}

#' @rdname badges
#' @export
use_bioc_badge <- function() {
  check_is_package("use_bioc_badge()")
  pkg <- project_name()

  src <- glue(
    "http://www.bioconductor.org/shields/build/release/bioc/{pkg}.svg"
  )
  href <- glue(
    "https://bioconductor.org/checkResults/release/bioc-LATEST/{pkg}"
  )
  use_badge("BioC status", href, src)

  invisible(TRUE)
}

#' @rdname badges
#' @export
use_lifecycle_badge <- function(stage) {
  check_is_package("use_lifecycle_badge()")
  pkg <- project_name()

  stage <- match.arg(tolower(stage), names(stages))
  colour <- stages[[stage]]

  src <- glue("https://img.shields.io/badge/lifecycle-{stage}-{colour}.svg")
  href <- glue("https://www.tidyverse.org/lifecycle/#{stage}")
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

  if (uses_github()) {
    url <- glue("https://mybinder.org/v2/gh/{github_repo_spec()}/master")
    img <- "http://mybinder.org/badge.svg"
    use_badge("Binder", url, img)
  }

  invisible(TRUE)
}



has_badge <- function(href) {
  readme_path <- proj_path("README.md")
  if (!file_exists(readme_path)) {
    return(FALSE)
  }

  readme <- readLines(readme_path)
  any(grepl(href, readme, fixed = TRUE))
}
