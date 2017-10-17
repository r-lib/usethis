#' Continuous integration
#'
#' @name ci
#' @aliases NULL
#' @inheritParams use_template
NULL


#' @section `use_travis`:
#' Add basic travis template to a package. Also adds `.travis.yml` to
#' `.Rbuildignore` so it isn't included in the built package.
#' @param browse open a browser window to enable Travis builds for the package
#' automatically.
#' @export
#' @rdname ci
use_travis <- function(browse = interactive()) {
  check_uses_github()

  use_template(
    "travis.yml",
    ".travis.yml",
    ignore = TRUE)

  use_travis_badge()
  travis_activate(browse)

  invisible(TRUE)
}


travis_info <- function(base_path = proj_get()) {
  gh <- gh::gh_tree_remote(base_path)

  url <- file.path("https://travis-ci.org", gh$username, gh$repo)
  img <- paste0(url, ".svg?branch=master")

  list(url = url, img = img)
}

use_travis_badge <- function() {
  travis <- travis_info(proj_get())
  use_badge("Travis build status", travis$url, travis$img)
}

travis_activate <- function(browse = interactive(), base_path = proj_get()) {
  travis <- travis_info(proj_get())

  todo("Turn on travis for your repo at ", travis$url)
  if (browse) {
    utils::browseURL(travis$url)
  }
}


uses_travis <- function(base_path = proj_get()) {
  path <- file.path(base_path, ".travis.yml")
  file.exists(path)
}

#' @rdname ci
#' @param type CI tool to use. Currently supports codecov and coverall.
#' @section `use_coverage`:
#' Add test code coverage to basic travis template to a package.
#' @export
use_coverage <- function(type = c("codecov", "coveralls")) {
  if (!uses_travis()) {
    stop("You must use_travis() first", call. = FALSE)
  }
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
    })

  invisible(TRUE)
}

use_codecov_badge <- function() {
  gh <- gh::gh_tree_remote(proj_get())

  use_badge("Coverage status",
    paste0("https://codecov.io/github/", gh$username, "/", gh$repo, "?branch=master"),
    paste0("https://codecov.io/gh/", gh$username, "/", gh$repo, "/branch/master/graph/badge.svg")
  )
}

use_coveralls_badge <- function() {
  gh <- gh::gh_tree_remote(proj_get())
  use_badge("Coverage status",
    paste0("https://coveralls.io/r/", gh$username, "/", gh$repo, "?branch=master"),
    paste0("https://coveralls.io/repos/github/", gh$username, "/", gh$repo, "/", "badge.svg")
  )
}

#' @rdname ci
#' @section `use_appveyor`:
#' Add basic AppVeyor template to a package. Also adds `appveyor.yml` to
#' `.Rbuildignore` so it isn't included in the built package.
#' @export
use_appveyor <- function() {
  use_template("appveyor.yml", ignore = TRUE)

  gh <- gh::gh_tree_remote(proj_get())
  todo("Turn on AppVeyor for this repo at https://ci.appveyor.com/projects\n")
  todo("Add an AppVeyor shield to your README.md:")
  code_block(paste0(
    "[![AppVeyor Build Status]",
    "(https://ci.appveyor.com/api/projects/status/github/", gh$username, "/", gh$repo, "?branch=master&svg=true)]",
    "(https://ci.appveyor.com/project/", gh$username, "/", gh$repo, ")"
  ))

  invisible(TRUE)
}
