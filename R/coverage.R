#' Test coverage
#'
#' Adds test coverage reporting to a package, using either Codecov
#' (`https://codecov.io`) or Coveralls (`https://coveralls.io`).
#'
#' @param type Which web service to use.
#' @eval param_repo_spec()
#' @export
use_coverage <- function(type = c("codecov", "coveralls"), repo_spec = NULL) {
  repo_spec <- repo_spec %||% target_repo_spec()
  use_dependency("covr", "Suggests")

  type <- match.arg(type)
  if (type == "codecov") {
    new <- use_template("codecov.yml", ignore = TRUE)
    if (!new) {
      return(invisible(FALSE))
    }
  } else if (type == "coveralls") {
    ui_todo("Turn on coveralls for this repo at https://coveralls.io/repos/new")
  }

  switch(
    type,
    codecov = use_codecov_badge(repo_spec),
    coveralls = use_coveralls_badge(repo_spec)
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
  default_branch <- git_branch_default()
  url <- glue("https://codecov.io/gh/{repo_spec}?branch={default_branch}")
  img <- glue("https://codecov.io/gh/{repo_spec}/branch/{default_branch}/graph/badge.svg")
  use_badge("Codecov test coverage", url, img)
}

use_coveralls_badge <- function(repo_spec) {
  default_branch <- git_branch_default()
  url <- glue("https://coveralls.io/r/{repo_spec}?branch={default_branch}")
  img <- glue("https://coveralls.io/repos/github/{repo_spec}/badge.svg")
  use_badge("Coveralls test coverage", url, img)
}
