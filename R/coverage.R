#' Test coverage
#'
#' `use_coverage()` Adds test coverage reports to a package.
#'
#' @param type Which web service to use for test reporting. Currently supports
#'   [Codecov](https://codecov.io) and [Coveralls](https://coveralls.io).
#' @export
use_coverage <- function(type = c("codecov", "coveralls")) {
  use_dependency("covr", "Suggests")

  type <- match.arg(type)
  if (type == "codecov") {
    new <- use_template("codecov.yml", ignore = TRUE)
    if (!new)  {
      return(invisible(FALSE))
    }
  } else if (type == "coveralls") {
    ui_todo("Turn on coveralls for this repo at https://coveralls.io/repos/new")
  }

  switch(type,
    codecov = use_codecov_badge(),
    coveralls = use_coveralls_badge()
  )

  ui_todo("Add to {ui_path('.travis.yml')}:")
  ui_code_block(
    "
    after_success:
      - Rscript -e 'covr::{type}()'
    "
  )

  invisible(TRUE)
}

#' @export
#' @rdname use_coverage
#' @param files Character vector of file globs.
use_covr_ignore <- function(files) {
  use_build_ignore(".covrignore")
  write_union(proj_path(".covrignore"), files)
}

use_codecov_badge <- function() {
  check_uses_github()
  url <- glue("https://codecov.io/gh/{github_repo_spec()}?branch=master")
  img <- glue(
    "https://codecov.io/gh/{github_repo_spec()}/branch/master/graph/badge.svg"
  )
  use_badge("Codecov test coverage", url, img)
}

use_coveralls_badge <- function() {
  check_uses_github()
  url <- glue("https://coveralls.io/r/{github_repo_spec()}?branch=master")
  img <- glue(
    "https://coveralls.io/repos/github/{github_repo_spec()}/badge.svg"
  )
  use_badge("Coveralls test coverage", url, img)
}
