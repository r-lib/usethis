#' Use lifecycle badges
#'
#' @description
#'
#' Call this to import the lifecycle badges and Rd macro into your
#' package.
#'
#' * The SVG badges are imported in `man/figures`.
#'
#' * The `RdMacros` field of the DESCRIPTION file is updated so you
#'   can use the `\lifecycle{}` macro in your documentation.
#'
#' See the [usage
#' vignette](https://lifecycle.r-lib.org/articles/usage.html) of the
#' lifecycle package.
#'
#' @seealso [use_lifecycle_badge()] to signal the (global lifecycle
#'   stage)[https://www.tidyverse.org/lifecycle/] of your package.
#'
#' @export
use_lifecycle <- function() {
  check_is_package("use_lifecycle()")

  use_package("lifecycle")
  use_rd_macros("lifecycle")

  dest_dir <- proj_path("man", "figures")
  create_directory(dest_dir)

  templ_dir <- path_package("usethis", "templates")
  templ_files <- dir_ls(templ_dir, glob = "*/lifecycle-*.svg")

  purrr::walk(templ_files, file_copy, dest_dir, overwrite = TRUE)
  ui_done("Copied SVG badges to {ui_path(dest_dir)}")

  macro <- "\\Sexpr[results=rd, stage=render]{lifecycle::badge(\"stage\")}"
  ui_todo(
    "
    Add badges in documentation topics by inserting this macro:

      { macro }

    You can choose from the following lifecycle stages:

    - \"experimental\"
    - \"maturing\"
    - \"stable\"
    - \"questioning\"
    - \"soft-deprecated\"
    - \"deprecated\"
    - \"defunct\"
    - \"archived\"
    "
  )

  invisible(TRUE)
}
