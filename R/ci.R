#' @rdname infrastructure
#' @section \code{use_travis}:
#' Add basic travis template to a package. Also adds \code{.travis.yml} to
#' \code{.Rbuildignore} so it isn't included in the built package.
#' @param browse open a browser window to enable Travis builds for the package
#' automatically.
#' @export
#' @aliases add_travis
use_travis <- function(pkg = ".", browse = interactive()) {
  pkg <- as.package(pkg)

  use_template("travis.yml", ".travis.yml", ignore = TRUE, pkg = pkg)

  gh <- github_info(pkg$path)
  travis_url <- file.path("https://travis-ci.org", gh$fullname)

  message("Next: \n",
    " * Add a travis shield to your README.md:\n",
    "[![Travis-CI Build Status]",
       "(https://travis-ci.org/", gh$fullname, ".svg?branch=master)]",
       "(https://travis-ci.org/", gh$fullname, ")\n",
    " * Turn on travis for your repo at ", travis_url, "\n"
  )
  if (browse) {
    utils::browseURL(travis_url)
  }

  invisible(TRUE)
}


#' @rdname infrastructure
#' @param type CI tool to use. Currently supports codecov and coverall.
#' @section \code{use_coverage}:
#' Add test code coverage to basic travis template to a package.
#' @export
use_coverage <- function(pkg = ".", type = c("codecov", "coveralls")) {
  pkg <- as.package(pkg)
  check_suggested("covr")

  path <- file.path(pkg$path, ".travis.yml")
  if (!file.exists(path)) {
    use_travis()
  }

  message("* Adding covr to Suggests")
  add_desc_package(pkg, "Suggests", "covr")

  gh <- github_info(pkg$path)
  type <- match.arg(type)

  message("Next:")
  switch(type,
    codecov = {
      use_template("codecov.yml", "codecov.yml", ignore = TRUE, pkg = pkg)
      message("* Add to `README.md`: \n",
        "[![Coverage Status]",
        "(https://img.shields.io/codecov/c/github/", gh$fullname, "/master.svg)]",
        "(https://codecov.io/github/", gh$fullname, "?branch=master)"
      )
      message("* Add to `.travis.yml`:\n",
        "after_success:\n",
        "  - Rscript -e 'covr::codecov()'"
      )
    },

    coveralls = {
      message("* Turn on coveralls for this repo at https://coveralls.io/repos/new")
      message("* Add to `README.md`: \n",
        "[![Coverage Status]",
        "(https://img.shields.io/coveralls/", gh$fullname, ".svg)]",
        "(https://coveralls.io/r/", gh$fullname, "?branch=master)"
      )
      message("* Add to `.travis.yml`:\n",
        "after_success:\n",
        "  - Rscript -e 'covr::coveralls()'"
      )
    })

  invisible(TRUE)
}

#' @rdname infrastructure
#' @section \code{use_appveyor}:
#' Add basic AppVeyor template to a package. Also adds \code{appveyor.yml} to
#' \code{.Rbuildignore} so it isn't included in the built package.
#' @export
use_appveyor <- function(pkg = ".") {
  pkg <- as.package(pkg)

  use_template("appveyor.yml", ignore = TRUE, pkg = pkg)

  gh <- github_info(pkg$path)
  message("Next: \n",
          " * Turn on AppVeyor for this repo at https://ci.appveyor.com/projects\n",
          " * Add an AppVeyor shield to your README.md:\n",
          "[![AppVeyor Build Status]",
          "(https://ci.appveyor.com/api/projects/status/github/", gh$username, "/", gh$repo, "?branch=master&svg=true)]",
          "(https://ci.appveyor.com/project/", gh$username, "/", gh$repo, ")"
  )

  invisible(TRUE)
}
