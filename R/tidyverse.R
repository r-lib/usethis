#' Helpers for the tidyverse
#'
#' These helpers follow tidyverse conventions which are generally a little
#' stricter than the defaults, reflecting the need for greater rigor in
#' commonly used packages
#'
#' @details
#'
#' * `use_tidy_ci()`: sets up travis and codecov
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

  use_dependency("covr", "Suggests", base_path = base_path)

  travis_badge(base_path = base_path)
  codecov_badge(base_path = base_path)

  if (new) {
    travis_activate(browse, base_path = base_path)
  }

  invisible(TRUE)
}
