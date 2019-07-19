#' Helpers from the r-lib organisation
#'
#' @details
#'
#' * `use_lifecycle()`: adds a dependency on the lifecycle
#'   package and imports the lifecycle SVG badges to the `man/figures`
#'   folder. See [lifecycle::badge()] for how to incorporate these
#'   badges in your documentation.
#'
#' @name r-lib
NULL

#' @rdname r-lib
#' @export
use_lifecycle <- function() {
  check_is_package("use_lifecycle()")

  use_package("lifecycle")

  dest_dir <- fs::dir_create(fs::path(proj_get(), "man", "figures"))
  templ_dir <- fs::path_package("usethis", "templates")
  templ_files <- fs::dir_ls(templ_dir, glob = "*/lifecycle-*.svg")

  purrr::walk(templ_files, fs::file_copy, dest_dir, overwrite = TRUE)
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

