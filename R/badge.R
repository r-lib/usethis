#' README badges
#'
#' These helpers produce the markdown text you need in your README to include
#' badges that report information, such as the CRAN version or test coverage,
#' and link out to relevant external resources. To allow badges to be added
#' automatically, ensure your badge block starts with a line containing only
#' `<!-- badges: start -->` and ends with a line containing only
#' `<!-- badges: end -->`. The templates used by [use_readme_md()] and
#' [use_readme_rmd()] include this block.
#'
#' @details
#'
#' * `use_badge()`: a general helper used in all badge functions
#' * `use_bioc_badge()`: badge indicates [BioConductor build
#' status](https://bioconductor.org/developers/)
#' * `use_cran_badge()`: badge indicates what version of your package is
#' available on CRAN, powered by <https://www.r-pkg.org>
#' * `use_lifecycle_badge()`: badge declares the developmental stage of a
#' package according to <https://lifecycle.r-lib.org/articles/stages.html>.
#' * `use_r_universe_badge()`: `r lifecycle::badge("experimental")` badge
#' indicates what version of your package is available on [R-universe
#' ](https://r-universe.dev/search/). It is assumed that you have already
#' completed the
#' [necessary R-universe setup](https://docs.r-universe.dev/publish/set-up.html).
#' * `use_binder_badge()`: badge indicates that your repository can be launched
#' in an executable environment on <https://mybinder.org/>
#' * `use_posit_cloud_badge()`: badge indicates that your repository can be launched
#' in a [Posit Cloud](https://posit.cloud) project
#' * `use_rscloud_badge()`: `r lifecycle::badge("deprecated")` Use
#' [use_posit_cloud_badge()] instead.
#'
#' @param badge_name Badge name. Used in error message and alt text
#' @param href,src Badge link and image src
#' @param stage Stage of the package lifecycle. One of "experimental",
#'   "stable", "superseded", or "deprecated".
#' @eval param_repo_spec()
#' @seealso [use_github_action()] helps with the setup of various continuous
#'   integration workflows, some of which will call these specialized badge
#'   helpers.
#'
#' @name badges
#' @examples
#' \dontrun{
#' use_cran_badge()
#' use_lifecycle_badge("stable")
#' # If you don't have a GitHub repo, or needs something extra
#' # you can create the r-universe badge
#' use_badge(
#'   "R-universe",
#'   "https://{organization}.r-universe.dev/badges/{package})",
#'   "https://{organization}.r-universe.dev/{package}"
#' )
#' }
NULL

#' @rdname badges
#' @export
use_badge <- function(badge_name, href, src) {
  path <- find_readme()
  if (is.null(path)) {
    ui_bullets(c(
      "!" = "Can't find a README for the current project.",
      "i" = "See {.fun usethis::use_readme_rmd} for help creating this file.",
      "i" = "Badge link will only be printed to screen."
    ))
    path <- "README"
  }
  changed <- block_append(
    glue("{badge_name} badge"),
    glue("[![{badge_name}]({src})]({href})"),
    path = path,
    block_start = badge_start,
    block_end = badge_end
  )

  if (changed && path_ext(path) == "Rmd") {
    ui_bullets(c(
      "_" = "Re-knit {.path {pth(path)}} with {.run devtools::build_readme()}."
    ))
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

  stage <- tolower(stage)
  stage <- arg_match0(stage, names(stages))
  colour <- stages[[stage]]

  src <- glue("https://img.shields.io/badge/lifecycle-{stage}-{colour}.svg")
  href <- glue("https://lifecycle.r-lib.org/articles/stages.html#{stage}")
  use_badge(paste0("Lifecycle: ", stage), href, src)

  invisible(TRUE)
}

stages <- c(
  experimental = "orange",
  stable = "brightgreen",
  superseded = "blue",
  deprecated = "orange"
)

#' @rdname badges
#' @param ref A Git branch, tag, or SHA
#' @param urlpath An optional `urlpath` component to add to the link, e.g.
#'   `"rstudio"` to open an RStudio IDE instead of a Jupyter notebook. See the
#'   [binder
#'   documentation](https://mybinder.readthedocs.io/en/latest/howto/user_interface.html)
#'    for additional examples.
#' @export
use_binder_badge <- function(ref = git_default_branch(), urlpath = NULL) {
  repo_spec <- target_repo_spec()

  if (is.null(urlpath)) {
    urlpath <- ""
  } else {
    urlpath <- glue("?urlpath={urlpath}")
  }
  url <- glue("https://mybinder.org/v2/gh/{repo_spec}/{ref}{urlpath}")
  img <- "https://mybinder.org/badge_logo.svg"
  use_badge("Launch binder", url, img)

  invisible(TRUE)
}
#' @rdname badges
#' @export
use_r_universe_badge <- function(repo_spec = NULL) {
  check_is_package("use_r_universe_badge()")
  pkg <- project_name()

  if (is.null(repo_spec)) {
    this_env <- current_call()
    tryCatch(
      github_url <- github_url(),
      error = function(e) {
        ui_abort(
          c(
            "x" = "Can't determine the R-universe owner of the {.pkg {pkg}} package.",
            "!" = "No GitHub URL found in DESCRIPTION or the Git remotes.",
            "i" = "Update the project configuration or provide an explicit {.arg repo_spec}."
          ),
          call = this_env
        )
      }
    )
    repo_spec <- parse_repo_url(github_url)[["repo_spec"]]
  }

  owner <- parse_repo_spec(repo_spec)[["owner"]]
  src <- glue("https://{owner}.r-universe.dev/{pkg}/badges/version")
  href <- glue("https://{owner}.r-universe.dev/{pkg}")
  use_badge("R-universe version", href, src)
}

#' @rdname badges
#' @param url A link to an existing [Posit Cloud](https://posit.cloud)
#'   project. See the [Posit Cloud
#'   documentation](https://posit.cloud/learn/guide#project-settings-access)
#'   for details on how to set project access and obtain a project link.
#' @export
use_posit_cloud_badge <- function(url) {
  check_name(url)
  project_url <- "posit[.]cloud/content"
  spaces_url <- "posit[.]cloud/spaces"
  if (grepl(project_url, url) || grepl(spaces_url, url)) {
    # TODO: Get posit logo hosted at https://github.com/simple-icons/simple-icons/
    # and add to end of img url as `?logo=posit` (or whatever slug we get)
    img <- "https://img.shields.io/badge/launch-posit%20cloud-447099?style=flat"
    use_badge("Launch Posit Cloud", url, img)
  } else {
    ui_abort(
      "
      {.fun usethis::use_posit_cloud_badge} requires a link to an
      existing Posit Cloud project of the form
      {.val https://posit.cloud/content/<project-id>} or
      {.val https://posit.cloud/spaces/<space-id>/content/<project-id>}."
    )
  }

  invisible(TRUE)
}

has_badge <- function(href) {
  readme_path <- proj_path("README.md")
  if (!file_exists(readme_path)) {
    return(FALSE)
  }

  readme <- read_utf8(readme_path)
  any(grepl(href, readme, fixed = TRUE))
}

# Badge data structure ----------------------------------------------------

badge_start <- "<!-- badges: start -->"
badge_end <- "<!-- badges: end -->"

find_readme <- function() {
  path_first_existing(proj_path(c("README.Rmd", "README.md")))
}
