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

  type <- match.arg(type)
  if (type == "codecov") {
    new <- use_template("codecov.yml", ignore = TRUE)
    if (new) {
      ui_bullets(c(
        "!" = "If test coverage uploads do not succeed, you probably need to
               configure {.env CODECOV_TOKEN} as a repository or organization
               secret:
               {.url https://docs.codecov.com/docs/adding-the-codecov-token}."
      ))
    } else {
      return(invisible(FALSE))
    }
  } else if (type == "coveralls") {
    ui_bullets(c(
      "_" = "Turn on coveralls for this repo at {.url https://coveralls.io/repos/new}."
    ))
  }

  switch(
    type,
    codecov = use_codecov_badge(repo_spec),
    coveralls = use_coveralls_badge(repo_spec)
  )

  ui_bullets(c(
    "_" = "Call {.run [use_github_action(\"test-coverage\")](usethis::use_github_action(\"test-coverage\"))}
           to continuously monitor test coverage."
  ))

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
  url <- glue("https://app.codecov.io/gh/{repo_spec}")
  img <- glue("https://codecov.io/gh/{repo_spec}/graph/badge.svg")
  use_badge("Codecov test coverage", url, img)
}

use_coveralls_badge <- function(repo_spec) {
  default_branch <- git_default_branch()
  url <- glue("https://coveralls.io/r/{repo_spec}?branch={default_branch}")
  img <- glue("https://coveralls.io/repos/github/{repo_spec}/badge.svg")
  use_badge("Coveralls test coverage", url, img)
}
