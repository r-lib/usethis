#' Continuous integration setup and badges
#'
#' Sets up continuous integration (CI) services for an R package that is
#' developed on GitHub with CI-agnostic support by \pkg{tic}.
#' CI services can run `R CMD check` automatically on
#' various platforms, triggered by each push or pull request. This function
#' * Adds service-specific configuration files and adds them to `.Rbuildignore`.
#' * Activates a service or gives the user a detailed prompt.\cr
#'
#' @details
#' By default the CI-services "Travis" (Linux) and "Appveyor"
#' (Windows) are used. Basic `.travis.yml` and `appveyor.yml` files are added
#' to the top-level directory of a package.
#'
#' @name use_ci
#' @import travis
#' @param path `[string]`\cr
#'   The path to the repo to prepare.
#' @param quiet `[flag]`\cr
#'   Less verbose output? Default: `FALSE`.
#' @param services `[character]`\cr
#'   CI services to add.
#' @export
#' @rdname ci
use_ci <- function(path = ".", quiet = FALSE,
                   services = c("Travis", "Appveyor")) {
  #' @details
  #' The following steps will be run:
  withr::with_dir(path, {
    #' 1. If necessary, create a GitHub repository via [use_github()]
    travis:::use_github_interactive()
    stopifnot(uses_github())

    if ("Travis" %in% services) {
      #' 1. Enable Travis via [travis_enable()]
      travis_enable()

      #' 1. Create a default `.travis.yml` file
      #'    (overwrite after confirmation in interactive mode only)
      travis:::use_travis_yml()
    }

    if ("Appveyor" %in% services) {
      #' 1. Create a default `appveyor.yml` file
      #'    (depending on repo type, overwrite after confirmation
      #'    in interactive mode only)
      repo_type <- travis:::detect_repo_type()
      if (travis:::needs_appveyor(repo_type)) travis:::use_appveyor_yml()
    }

    #' 1. Create a default `tic.R` file depending on the repo type
    #'    (package, website, bookdown, ...)
    travis:::use_tic_r(repo_type)

    #' 1. Enable deployment (if necessary, depending on repo type)
    #'    via [use_travis_deploy()]
    if (travis:::needs_deploy(repo_type)) use_travis_deploy()

    #' 1. Create a GitHub PAT and install it on Travis CI via [travis_set_pat()]
    travis_set_pat()
  })

  #'
  #' This function is aimed at supporting the most common use cases.
  #' Users who require more control are advised to manually call the individual
  #' functions.
}

use_travis_badge <- function() {
  uses_github()

  url <- glue("https://travis-ci.org/{github_repo_spec()}")
  img <- glue("{url}.svg?branch=master")

  use_badge("Travis build status", url, img)
}

#' @importFrom travis travis_is_enabled
#' @section `use_coverage()`:
#' Adds test coverage reports to a package that is already using Travis CI.
#' @name use_coverage
#' @param type Which web service to use for test reporting. Currently supports
#'   [Codecov](https://codecov.io) and [Coveralls](https://coveralls.io).
#' @export
use_coverage <- function(type = c("codecov", "coveralls")) {
  travis:::travis_is_enabled()
  type <- match.arg(type)

  use_dependency("covr", "Suggests")

  switch(type,
    codecov = {
      use_template("codecov.yml", ignore = TRUE)
      use_codecov_badge()
      todo("Add to {value('.travis.yml')}:")
      code_block(
        "after_success:",
        "  - Rscript -e 'covr::codecov()'"
      )
    },

    coveralls = {
      todo("Turn on coveralls for this repo at https://coveralls.io/repos/new")
      use_coveralls_badge()
      todo("Add to {value('.travis.yml')}:")
      code_block(
        "after_success:",
        "  - Rscript -e 'covr::coveralls()'"
      )
    }
  )

  invisible(TRUE)
}

use_codecov_badge <- function() {
  uses_github()
  url <- glue("https://codecov.io/github/{github_repo_spec()}?branch=master")
  img <- glue(
    "https://codecov.io/gh/{github_repo_spec()}/branch/master/graph/badge.svg"
  )
  use_badge("Coverage status", url, img)
}

use_coveralls_badge <- function() {
  uses_github()
  url <- glue("https://coveralls.io/r/{github_repo_spec()}?branch=master")
  img <- glue(
    "https://coveralls.io/repos/github/{github_repo_spec()}/badge.svg"
  )
  use_badge("Coverage status", url, img)
}
