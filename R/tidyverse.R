#' Helpers for the tidyverse
#'
#' These helpers follow tidyverse conventions which are generally a little
#' stricter than the defaults, reflecting the need for greater rigor in
#' commonly used packages
#'
#' @details
#'
#' * `use_tidy_ci()`: sets up travis and codecov, ensuring that the package
#'    works on all version of R starting at 3.1.
#'
#' * `use_tidy_description()`: puts fields in standard order and alphabetises
#'   dependencies.
#'
#' * `use_tidy_eval()`: imports a standard set of helpers to faciliate
#'   programming with the tidy eval toolkit.
#'
#' @md
#' @name tidyverse
NULL

#' @export
#' @rdname tidyverse
#' @inheritParams use_travis
use_tidy_ci <- function(browse = interactive(), base_path = ".") {
  check_uses_github(base_path)

  new <- use_template(
    "tidy-travis.yml",
    ".travis.yml",
    ignore = TRUE,
    base_path = base_path
  )
  use_template("codecov.yml", ignore = TRUE, base_path = base_path)

  use_dependency("R", "Depends", ">= 3.1", base_path = base_path)
  use_dependency("covr", "Suggests", base_path = base_path)

  travis_badge(base_path = base_path)
  codecov_badge(base_path = base_path)

  if (new) {
    travis_activate(browse, base_path = base_path)
  }

  invisible(TRUE)
}


#' @export
#' @rdname tidyverse
use_tidy_description <- function(base_path = ".") {

  deps <- desc::desc_get_deps(base_path)
  deps <- deps[order(deps$type, deps$package), , drop = FALSE]
  desc::desc_del_deps(file = base_path)
  desc::desc_set_deps(deps, file = base_path)

  desc::desc_reorder_fields(file = base_path)

  invisible(TRUE)
}


#' @export
#' @rdname tidyverse
use_tidy_eval <- function(base_path = ".") {
  if (!uses_roxygen(base_path)) {
    stop("`use_tidy_eval()` requires that you use roxygen.", call. = FALSE)
  }

  use_dependency("rlang", "imports", ">= 0.1.2", base_path = base_path)
  use_template(
    "tidy-eval.R",
    "R/utils-tidy-eval.R",
    base_path = base_path
  )

  todo("Run document()")
}
