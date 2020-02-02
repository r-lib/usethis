#' README badges
#'
#' These helpers produce the markdown text you need in your README to include
#' badges that report information, such as the CRAN version or test coverage,
#' and link out to relevant external resources. To add badges automatically
#' ensure your badge block starts with a line containing only
#' `<!-- badges: start -->` and ends with a line containing only
#' `<!-- badges: end -->`.
#'
#' @details
#'
#' * `use_badge()`: a general helper used in all badge functions
#' * `use_bioc_badge()`: badge indicates [BioConductor build
#' status](https://bioconductor.org/developers/)
#' * `use_cran_badge()`: badge indicates what version of your package is
#' available on CRAN, powered by <https://www.r-pkg.org>
#' * `use_lifecycle_badge()`: badge declares the developmental stage of a
#' package, according to <https://www.tidyverse.org/lifecycle/>:
#'   - Experimental
#'   - Maturing
#'   - Stable
#'   - Superseded
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
  path <- find_readme()
  changed <- block_append(
    glue("{ui_field(badge_name)} badge"),
    glue("[![{badge_name}]({src})]({href})"),
    path = path,
    block_start = badge_start,
    block_end = badge_end
  )

  if (changed && path_ext(path) == "Rmd") {
    ui_todo("Re-knit {ui_path(path)}")
  }
  invisible(changed)
}

#' @rdname badges
#' @export
use_cran_badge <- function() {
  check_is_package("use_cran_badge()")
  pkg <- project_name()

  src <- glue("https://www.r-pkg.org/badges/version/{pkg}")
  href <- glue("https://CRAN.R-project.org/package={pkg}")
  use_badge("CRAN status", href, src)

  invisible(TRUE)
}

#' @rdname badges
#' @export
use_bioc_badge <- function() {
  check_is_package("use_bioc_badge()")
  pkg <- project_name()

  src <- glue("http://www.bioconductor.org/shields/build/release/bioc/{pkg}.svg")
  href <- glue("https://bioconductor.org/checkResults/release/bioc-LATEST/{pkg}")
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
  use_badge(paste0("Lifecycle: ", stage), href, src)

  invisible(TRUE)
}

stages <- c(
  experimental = "orange",
  maturing = "blue",
  stable = "brightgreen",
  superseded = "blue",
  archived = "red",
  dormant = "blue",
  questioning = "blue"
)

#' @rdname badges
#' @param urlpath An optional `urlpath` component to add to the link, e.g. `"rstudio"`
#'   to open an RStudio IDE instead of a Jupyter notebook.
#'   See the [binder documentation](https://mybinder.readthedocs.io/en/latest/howto/user_interface.html)
#'   for additional examples.
#' @export
use_binder_badge <- function(urlpath = NULL) {
  check_uses_github()

  if (is.null(urlpath)) {
    urlpath <- ""
  } else {
    urlpath <- glue("?urlpath={urlpath}")
  }
  url <- glue("https://mybinder.org/v2/gh/{github_repo_spec()}/master{urlpath}")
  img <- "https://mybinder.org/badge_logo.svg"
  use_badge("Launch binder", url, img)

  invisible(TRUE)
}

has_badge <- function(href) {
  readme_path <- proj_path("README.md")
  if (!file_exists(readme_path)) {
    return(FALSE)
  }

  readme <- readLines(readme_path, encoding = "UTF-8")
  any(grepl(href, readme, fixed = TRUE))
}

# Badge data structure ----------------------------------------------------

badge_start <- "<!-- badges: start -->"
badge_end <- "<!-- badges: end -->"

find_readme <- function() {
  path_first_existing(proj_path(c("README.Rmd", "README.md")))
}
