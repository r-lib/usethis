#' Test coverage
#'
#' `use_coverage()` adds test coverage reports to a package.
#'
#' @param type Which web service to use for test reporting. Currently supports
#'   [Codecov](https://codecov.io) and [Coveralls](https://coveralls.io).
#' @param repo_spec GitHub repo specification in this form: `owner/repo`.
#'   Default is to infer from GitHub remotes of active project.
#' @export
use_coverage <- function(type = c("codecov", "coveralls"), repo_spec = NULL) {
  if (is.null(repo_spec)) {
    remote <- get_github_primary()
    repo_spec <- remote$repo_spec
    if (remote$in_fork) {
      ui_info("
        Working in a fork, so badge link is based on the parent repo, which \\
        is {ui_value(repo_spec)}")
    }
  } else {
    remote <- NULL
  }
  use_dependency("covr", "Suggests")

  type <- match.arg(type)
  if (type == "codecov") {
    new <- use_template("codecov.yml", ignore = TRUE)
    if (!new) {
      return(invisible(FALSE))
    }
  } else if (type == "coveralls") {
    if (!is.null(remote) && !remote$can_push) {
      ui_oops("
        You don't seem to have push access to the primary repo, \\
        {ui_value(remote$repo_spec)}.
        Someone with more permission may need to activate Coveralls.
        ")
    }
    ui_todo("Turn on coveralls for this repo at https://coveralls.io/repos/new")
  }

  switch(type,
    codecov = use_codecov_badge(remote$repo_spec),
    coveralls = use_coveralls_badge(remote$repo_spec)
  )

  if (uses_travis()) {
    ui_todo("Add to {ui_path('.travis.yml')}:")
    ui_code_block("
      after_success:
        - Rscript -e 'covr::{type}()'
      ")
  }

  invisible(TRUE)
}

#' @export
#' @rdname use_coverage
#' @param files Character vector of file globs.
use_covr_ignore <- function(files) {
  use_build_ignore(".covrignore")
  write_union(proj_path(".covrignore"), files)
}

use_codecov_badge <- function(repo_spec) {
  url <- glue("https://codecov.io/gh/{repo_spec}?branch=master")
  img <- glue("https://codecov.io/gh/{repo_spec}/branch/master/graph/badge.svg")
  use_badge("Codecov test coverage", url, img)
}

use_coveralls_badge <- function(repo_spec) {
  url <- glue("https://coveralls.io/r/{repo_spec}?branch=master")
  img <- glue("https://coveralls.io/repos/github/{repo_spec}/badge.svg")
  use_badge("Coveralls test coverage", url, img)
}
