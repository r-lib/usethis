#' Continuous integration setup and badges
#'
#' Sets up continuous integration (CI) services for an R package that is
#' developed on GitHub. CI services can run `R CMD check` automatically on
#' various platforms, triggered by each push or pull request. These functions
#' * Add service-specific configuration files and add them to `.Rbuildignore`.
#' * Activate a service or give the user a detailed prompt.
#' * Provide the markdown to insert a badge into README.
#'
#' @name ci
#' @aliases NULL
NULL

#' @section `use_travis()`:
#' Adds a basic `.travis.yml` to the top-level directory of a package. This is a
#' configuration file for the [Travis CI](https://travis-ci.org/) continuous
#' integration service.
#' @param browse Open a browser window to enable automatic builds for the
#'   package.
#' @export
#' @rdname ci
use_travis <- function(browse = interactive()) {
  check_uses_github()

  use_template(
    "travis.yml",
    ".travis.yml",
    ignore = TRUE
  )

  travis_activate(browse)
  use_travis_badge()

  invisible(TRUE)
}

use_travis_badge <- function() {
  gh <- gh::gh_tree_remote(proj_get())

  url <- file.path("https://travis-ci.org", gh$username, gh$repo)
  img <- paste0(url, ".svg?branch=master")

  use_badge("Travis build status", url, img)
}

travis_activate <- function(browse = interactive(), base_path = proj_get()) {
  gh <- gh::gh_tree_remote(base_path)
  url <- file.path("https://travis-ci.org/profile", gh$username)

  todo("Turn on travis for your repo at ", url)
  if (browse) {
    utils::browseURL(url)
  }
}

uses_travis <- function(base_path = proj_get()) {
  path <- file.path(base_path, ".travis.yml")
  file.exists(path)
}

check_uses_travis <- function(base_path = proj_get()) {
  if (uses_travis(base_path)) {
    return(invisible())
  }

  stop(
    "Cannot detect that package ", value(project_name(base_path)),
    " already uses Travis.\n",
    "Do you need to run ", code("use_travis()"), "?",
    call. = FALSE
  )
}

#' @section `use_coverage()`:
#' Adds test coverage reports to a package that is already using Travis CI.
#' @rdname ci
#' @param type Which web service to use for test reporting. Currently supports
#'   [Codecov](https://codecov.io) and [Coveralls](https://coveralls.io).
#' @export
use_coverage <- function(type = c("codecov", "coveralls")) {
  check_uses_travis()
  type <- match.arg(type)

  use_dependency("covr", "Suggests")

  switch(type,
    codecov = {
      use_template("codecov.yml", ignore = TRUE)
      use_codecov_badge()
      todo("Add to ", value(".travis.yml"), ":")
      code_block(
        "after_success:",
        "  - Rscript -e 'covr::codecov()'"
      )
    },

    coveralls = {
      todo("Turn on coveralls for this repo at https://coveralls.io/repos/new")
      use_coveralls_badge()
      todo("Add to ", value(".travis.yml"), ":")
      code_block(
        "after_success:",
        "  - Rscript -e 'covr::coveralls()'"
      )
    }
  )

  invisible(TRUE)
}

use_codecov_badge <- function() {
  gh <- gh::gh_tree_remote(proj_get())
  url <- paste0(
    "https://codecov.io/github/", gh$username, "/", gh$repo, "?branch=master"
  )
  img <- file.path(
    "https://codecov.io/gh", gh$username, gh$repo,
    "branch/master/graph/badge.svg"
  )
  use_badge("Coverage status", url, img)
}

use_coveralls_badge <- function() {
  gh <- gh::gh_tree_remote(proj_get())
  url <- paste0(
    "https://coveralls.io/r/", gh$username, "/", gh$repo, "?branch=master"
  )
  img <- file.path(
    "https://coveralls.io/repos/github", gh$username, gh$repo, "badge.svg"
  )
  use_badge("Coverage status", url, img)
}

#' @section `use_appveyor()`:
#' Adds a basic `appveyor.yml` to the top-level directory of a package. This is
#' a configuration file for the [AppVeyor](https://www.appveyor.com) continuous
#' integration service for Windows.
#' @export
#' @rdname ci
use_appveyor <- function(browse = interactive()) {
  check_uses_github()

  use_template("appveyor.yml", ignore = TRUE)

  appveyor_activate(browse)
  use_appveyor_badge()

  invisible(TRUE)
}

appveyor_activate <- function(browse = interactive()) {
  url <- "https://ci.appveyor.com/projects/new"
  todo("Turn on AppVeyor for this repo at ", url)
  if (browse) {
    utils::browseURL(url)
  }
}

use_appveyor_badge <- function() {
  appveyor <- appveyor_info(proj_get())
  use_badge("AppVeyor build status", appveyor$url, appveyor$img)
}

appveyor_info <- function(base_path = proj_get()) {
  gh <- gh::gh_tree_remote(base_path)
  img <- paste0(
    "https://ci.appveyor.com/api/projects/status/github/",
    gh$username,
    "/",
    gh$repo,
    "?branch=master&svg=true"
  )
  url <- file.path(
    "https://ci.appveyor.com",
    "project",
    gh$username,
    gh$repo
  )

  list(url = url, img = img)
}
