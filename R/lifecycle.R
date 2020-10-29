#' Use lifecycle badges
#'
#' @description
#'
#' Call this to copy the lifecycle badges into your package (`man/figures`)
#' and remind you of the syntax to use.
#'
#' See the [getting started
#' vignette](https://lifecycle.r-lib.org/articles/lifecycle.html) of the
#' lifecycle package.
#'
#' @seealso [use_lifecycle_badge()] to signal the [global lifecycle
#'   stage](https://www.tidyverse.org/lifecycle/) of your package.
#'
#' @export
use_lifecycle <- function() {
  check_is_package("use_lifecycle()")

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
    "- `r lifecycle::badge('experimental') `",
    "- `r lifecycle::badge('maturing') `",
    "- `r lifecycle::badge('stable') `",
    "- `r lifecycle::badge('superseded') `",
    "- `r lifecycle::badge('questioning') `",
    "- `r lifecycle::badge('soft-deprecated') `",
    "- `r lifecycle::badge('deprecated') `",
    "- `r lifecycle::badge('defunct') `",
    "- `r lifecycle::badge('archived') `",
  ))

  invisible(TRUE)
}

use_rd_macros <- function(package) {
  proj <- proj_get()

  if (desc::desc_has_fields("RdMacros", file = proj)) {
    macros <- desc::desc_get_field("RdMacros", file = proj)
    macros <- strsplit(macros, ",")[[1]]
    macros <- gsub("^\\s+|\\s+$", "", macros)
  } else {
    macros <- character()
  }

  if (!package %in% macros) {
    macros <- c(macros, package)
    desc::desc_set(RdMacros = paste0(macros, collapse = ", "), file = proj)
  }

  invisible()
}
