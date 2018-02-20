#' Helpers for the tidyverse
#'
#' These helpers follow tidyverse conventions which are generally a little
#' stricter than the defaults, reflecting the need for greater rigor in
#' commonly used packages.
#'
#' @details
#'
#' * `use_tidy_ci()`: sets up travis and codecov, ensuring that the package
#'    works on all versions of R starting at 3.1.
#'
#' * `use_tidy_description()`: puts fields in standard order and alphabetises
#'   dependencies.
#'
#' * `use_tidy_eval()`: imports a standard set of helpers to facilitate
#'   programming with the tidy eval toolkit.
#'
#' * `use_tidy_style()`: styles source code according to the [tidyverse style
#' guide](http://style.tidyverse.org). This function will overwrite files! See
#' below for usage advice.
#'
#' * `use_tidy_versions()`: pins all dependencies to require at least
#'   the currently installed version.
#'
#' * `use_tidy_contributing()`: adds standard tidyverse contributing guidelines.
#'
#' * `use_tidy_issue_template()`: adds a standard tidyverse issue template.
#'
#' * `use_tidy_support()`: adds a standard description of support resources for
#'    the tidyverse.
#'
#' * `use_tidy_coc()`: equivalent to `use_code_of_conduct()`, but puts the
#'    document in a `.github/` subdirectory.
#'
#' * `use_tidy_github()`: convenience wrapper that calls
#' `use_tidy_contributing()`, `use_tidy_issue_template()`, `use_tidy_support()`,
#' `use_tidy_coc()`.
#'
#' @section `use_tidy_style()`:
#' Uses the [styler package](http://styler.r-lib.org) package to style all code
#' in a package, project, or directory, according to the [tidyverse style
#' guide](http://style.tidyverse.org).
#'
#' **Warning:** This function will overwrite files! It is strongly suggested to
#' only style files that are under version control or to first create a backup
#' copy.
#'
#' Invisibly returns a data frame with one row per file, that indicates whether
#' styling caused a change.
#'
#' @param strict Boolean indicating whether or not a strict version of styling
#'   should be applied. See [styler::tidyverse_style()] for details.
#'
#' @name tidyverse
NULL


#' @export
#' @rdname tidyverse
#' @inheritParams use_travis
use_tidy_ci <- function(browse = interactive()) {
  check_uses_github()

  new <- use_template(
    "tidy-travis.yml",
    ".travis.yml",
    ignore = TRUE
  )
  use_template("codecov.yml", ignore = TRUE)

  use_dependency("R", "Depends", ">= 3.1")
  use_dependency("covr", "Suggests")

  use_travis_badge()
  use_codecov_badge()

  if (new) {
    travis_activate(browse)
  }

  invisible(TRUE)
}


#' @export
#' @rdname tidyverse
use_tidy_description <- function() {
  base_path <- proj_get()

  # Alphabetise dependencies
  deps <- desc::desc_get_deps(base_path)
  deps <- deps[order(deps$type, deps$package), , drop = FALSE]
  desc::desc_del_deps(file = base_path)
  desc::desc_set_deps(deps, file = base_path)

  # Alphabetise remotes
  remotes <- desc::desc_get_remotes(file = base_path)
  if (length(remotes) > 0) {
    desc::desc_set_remotes(sort(remotes), file = base_path)
  }

  # Reorder all fields
  desc::desc_reorder_fields(file = base_path)

  invisible(TRUE)
}


#' @export
#' @rdname tidyverse
#' @param overwrite By default (`FALSE`), only dependencies without version
#'   specifications will be modified. Set to `TRUE` to modify all dependencies.
use_tidy_versions <- function(overwrite = FALSE) {
  deps <- desc::desc_get_deps(proj_get())

  to_change <- deps$package != "R"
  if (!overwrite) {
    to_change <- to_change & deps$version == "*"
  }

  deps$version[to_change] <- vapply(deps$package[to_change], dep_version, character(1))
  desc::desc_set_deps(deps, file = proj_get())

  invisible(TRUE)
}

is_installed <- function(x) {
  length(find.package(x, quiet = TRUE)) > 0
}
dep_version <- function(x) {
  if (is_installed(x)) paste0(">= ", utils::packageVersion(x)) else "*"
}


#' @export
#' @rdname tidyverse
use_tidy_eval <- function() {
  if (!uses_roxygen()) {
    stop("`use_tidy_eval()` requires that you use roxygen.", call. = FALSE)
  }

  use_dependency("rlang", "Imports", ">= 0.1.2")
  use_template("tidy-eval.R", "R/utils-tidy-eval.R")

  todo("Run document()")
}


#' @export
#' @rdname tidyverse
use_tidy_contributing <- function() {
  check_uses_github()

  use_directory(".github", ignore = TRUE)
  use_template(
    "tidy-contributing.md",
    ".github/CONTRIBUTING.md",
    data = list(
      package = project_name()
    )
  )
}


#' @export
#' @rdname tidyverse
use_tidy_issue_template <- function() {
  check_uses_github()

  use_directory(".github", ignore = TRUE)
  use_template(
    "tidy-issue.md",
    ".github/ISSUE_TEMPLATE.md"
  )
}


#' @export
#' @rdname tidyverse
use_tidy_support <- function() {
  check_uses_github()

  use_directory(".github", ignore = TRUE)
  use_template(
    "tidy-support.md",
    ".github/SUPPORT.md",
    data = list(package = project_name())
  )
}


#' @export
#' @rdname tidyverse
use_tidy_coc <- function() {
  check_uses_github()

  use_directory(".github", ignore = TRUE)
  use_template(
    "CODE_OF_CONDUCT.md",
    ".github/CODE_OF_CONDUCT.md"
  )

  todo("Don't forget to describe the code of conduct in your README.md:")
  code_block(
    "Please note that this project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md).",
    "By participating in this project you agree to abide by its terms."
  )
}

#' @export
#' @rdname tidyverse
use_tidy_github <- function() {
  use_tidy_contributing()
  use_tidy_issue_template()
  use_tidy_support()
  use_tidy_coc()
}

#' @export
#' @rdname tidyverse
use_tidy_style <- function(strict = TRUE) {
  check_installed("styler")
  check_uncommitted_changes()
  if (is_package()) {
    styled <- styler::style_pkg(proj_get(),
                                style = styler::tidyverse_style, strict = strict
    )
  } else {
    styled <- styler::style_dir(proj_get(),
                                style = styler::tidyverse_style, strict = strict
    )
  }
  cat_line()
  done("Styled project according to the tidyverse style guide")
  invisible(styled)
}
