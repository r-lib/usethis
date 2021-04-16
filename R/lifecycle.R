#' Use lifecycle badges
#'
#' @description
#' This helper:
#'
#' * Adds lifecycle as a dependency.
#' * Imports [lifecycle::deprecated()] for use in function arguments.
#' * Copies the lifecycle badges into `man/figures`.
#' * Reminds you how to use the badge syntax.
#'
#' Learn more at <https://lifecycle.r-lib.org/articles/communicate.html>
#'
#' @seealso [use_lifecycle_badge()] to signal the
#'  [lifecycle stage](https://lifecycle.r-lib.org/articles/stages.html) of
#'  your package as whole
#' @export
use_lifecycle <- function() {
  check_is_package("use_lifecycle()")
  check_uses_roxygen("use_lifecycle()")
  if (!uses_roxygen_md()) {
    ui_stop("
      Turn on roxygen2 markdown support {ui_code('use_roxygen_md()')}")
  }

  use_package("lifecycle")
  use_import_from("lifecycle", "deprecated")

  dest_dir <- proj_path("man", "figures")
  create_directory(dest_dir)

  templ_dir <- path_package("usethis", "templates")
  templ_files <- dir_ls(templ_dir, glob = "*/lifecycle-*.svg")

  purrr::walk(templ_files, file_copy, dest_dir, overwrite = TRUE)
  ui_done("Copied SVG badges to {ui_path(dest_dir)}")

  ui_todo(c(
    "Add badges in documentation topics by inserting one of:",
    "#' `r lifecycle::badge('experimental')`",
    "#' `r lifecycle::badge('superseded')`",
    "#' `r lifecycle::badge('deprecated')`"
  ))

  invisible(TRUE)
}
