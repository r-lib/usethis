#' Test coverage
#'
#' `use_coverage()` Adds test coverage reports to a package that is already
#' using Travis CI.
#'
#' @param type Which web service to use for test reporting. Currently supports
#'   [Codecov](https://codecov.io) and [Coveralls](https://coveralls.io).
#' @export
use_coverage <- function(type = c("codecov", "coveralls")) {
  check_uses_travis()
  type <- match.arg(type)

  use_dependency("covr", "Suggests")

  if (type == "codecov") {
    new <- use_template("codecov.yml", ignore = TRUE)
    if (!new) return(invisible(FALSE))
  }

  if (type == "coveralls") {
    todo("Turn on coveralls for this repo at https://coveralls.io/repos/new")
  }

  switch(
    type,
    codecov = use_codecov_badge(),
    coveralls = use_coveralls_badge()
  )

  todo("Add to {value('.travis.yml')}:")
  code_block(
    "after_success:",
    "  - Rscript -e 'covr::{type}()'"
  )

  invisible(TRUE)
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
