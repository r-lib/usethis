#' Use lifecycle badges
#'
#' @description
#'
#' Call this to copy the lifecycle badges into your package (`man/figures`) and
#' remind you of the syntax to use them in the documentation of individual
#' functions or arguments.
#'
#' See the [getting started
#' vignette](https://lifecycle.r-lib.org/articles/lifecycle.html) of the
#' lifecycle package.
#'
#' @seealso [use_lifecycle_badge()] to signal the [global lifecycle
#'   stage](https://www.tidyverse.org/lifecycle/) of your package as a whole.
#'
#' @export
use_lifecycle <- function() {
  check_is_package("use_lifecycle()")
  check_uses_roxygen("use_lifecycle()")
  if (!uses_roxygen_md()) {
    ui_stop("
      Turn on roxygen2 markdown support {ui_code('use_roxygen_md()')}")
  }

  use_dependency("lifecycle", "imports")
  # silence R CMD check NOTE
  roxygen_ns_append("@importFrom lifecycle deprecate_soft")

  dest_dir <- proj_path("man", "figures")
  create_directory(dest_dir)

  templ_dir <- path_package("usethis", "templates")
  templ_files <- dir_ls(templ_dir, glob = "*/lifecycle-*.svg")

  purrr::walk(templ_files, file_copy, dest_dir, overwrite = TRUE)
  ui_done("Copied SVG badges to {ui_path(dest_dir)}")

  ui_todo(c(
    "Add badges in documentation topics by inserting one of:",
    "- `r lifecycle::badge('experimental')`",
    "- `r lifecycle::badge('maturing')`",
    "- `r lifecycle::badge('stable')`",
    "- `r lifecycle::badge('superseded')`",
    "- `r lifecycle::badge('questioning')`",
    "- `r lifecycle::badge('soft-deprecated')`",
    "- `r lifecycle::badge('deprecated')`",
    "- `r lifecycle::badge('defunct')`",
    "- `r lifecycle::badge('archived')`"
  ))

  invisible(TRUE)
}
