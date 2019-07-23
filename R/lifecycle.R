#' Helpers from the r-lib organisation
#'
#' @details
#'
#' * `use_lifecycle()`: adds a dependency on the lifecycle
#'   package and imports the lifecycle SVG badges to the `man/figures`
#'   folder. See [lifecycle::badge()] for how to incorporate these
#'   badges in your documentation.
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
