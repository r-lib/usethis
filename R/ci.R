#' Continuous integration setup and badges
#'
#' @description
#'
#' `r lifecycle::badge("deprecated")`
#'
#' Some of these functions are now soft-deprecated since the tidyverse team has
#' started using [GitHub Actions (GHA)](https://github.com/features/actions) for
#' continuous integration (CI). See [use_github_actions()] for help configuring
#' GHA. GHA functionality in usethis is actively maintained and exercised, which
#' is no longer true for Travis-CI or AppVeyor.
#'
#' Sets up third-party continuous integration (CI) services for an R package
#' that is developed on GitHub or, perhaps, GitLab. These functions
#' * Add service-specific configuration files and add them to `.Rbuildignore`.
#' * Activate a service or give the user a detailed prompt.
#' * Provide the markdown to insert a badge into README.
#'
#' @name ci
#' @aliases NULL
NULL

#' @section `use_travis()`:
#' Adds a basic `.travis.yml` to the top-level directory of a package. This is a
#' configuration file for the [Travis CI](https://travis-ci.com/) continuous
#' integration service.
#' @param browse Open a browser window to enable automatic builds for the
#'   package.
#' @param ext Which travis website to use. Defaults to `"com"` for
#'   https://travis-ci.com. Change to `"org"` for https://travis-ci.org.
#' @export
#' @rdname ci
use_travis <- function(browse = rlang::is_interactive(),
                       ext = c("com", "org")) {
  lifecycle::deprecate_soft(
    when = "2.0.0",
    what = "usethis::use_travis()",
    with = "use_github_actions()"
  )
  repo_spec <- target_repo_spec()
  ext <- arg_match(ext)
  new <- use_template(
    "travis.yml",
    ".travis.yml",
    ignore = TRUE
  )
  if (!new) {
    return(invisible(FALSE))
  }
  use_travis_badge(ext = ext, repo_spec = repo_spec)
  travis_activate(repo_spec, browse = browse, ext = ext)

  invisible(TRUE)
}

#' @section `use_travis_badge()`:
#' Only adds the [Travis CI](https://travis-ci.com/) badge. Use for a project
#'  where Travis is already configured.
#' @eval param_repo_spec()
#' @export
#' @rdname ci
use_travis_badge <- function(ext = c("com", "org"), repo_spec = NULL) {
  repo_spec <- repo_spec %||% target_repo_spec()
  ext <- arg_match(ext)
  url <- glue("https://travis-ci.{ext}/{repo_spec}")
  img <- glue("{url}.svg?branch={git_branch_default()}")
  use_badge("Travis build status", url, img)
}

travis_activate <- function(repo_spec,
                            browse = is_interactive(),
                            ext = c("com", "org")) {
  ext <- arg_match(ext)
  url <- glue("https://travis-ci.{ext}/profile/{repo_spec}")

  ui_todo("Turn on travis for the repo at {url}")
  if (browse) {
    utils::browseURL(url)
  }
}

uses_travis <- function() {
  file_exists(proj_path(".travis.yml"))
}

#' @section `use_appveyor()`:
#' Adds a basic `appveyor.yml` to the top-level directory of a package. This is
#' a configuration file for the [AppVeyor](https://www.appveyor.com) continuous
#' integration service for Windows.
#' @export
#' @rdname ci
use_appveyor <- function(browse = rlang::is_interactive()) {
  lifecycle::deprecate_soft(
    when = "2.0.0",
    what = "usethis::use_appveyor()",
    with = "use_github_actions()"
  )
  repo_spec <- target_repo_spec()
  new <- use_template("appveyor.yml", ignore = TRUE)
  if (!new) {
    return(invisible(FALSE))
  }

  use_appveyor_badge(repo_spec)
  appveyor_activate(browse)

  invisible(TRUE)
}

appveyor_activate <- function(browse = is_interactive()) {
  url <- "https://ci.appveyor.com/projects/new"
  ui_todo("Turn on AppVeyor for this repo at {url}")
  if (browse) {
    utils::browseURL(url)
  }
}

#' @section `use_appveyor_badge()`:
#' Only adds the [AppVeyor](https://www.appveyor.com) badge. Use for a project
#'  where AppVeyor is already configured.
#' @export
#' @rdname ci
use_appveyor_badge <- function(repo_spec = NULL) {
  repo_spec <- repo_spec %||% target_repo_spec()
  img <- glue(
    "https://ci.appveyor.com/api/projects/status/github/",
    "{repo_spec}?branch={git_branch_default()}&svg=true"
  )
  url <- glue("https://ci.appveyor.com/project/{repo_spec}")
  use_badge("AppVeyor build status", url, img)
}

#' @section `use_gitlab_ci()`:
#' Adds a basic `.gitlab-ci.yml` to the top-level directory of a package. This
#' is a configuration file for the [GitLab
#' CI/CD](https://docs.gitlab.com/ee/ci/) continuous integration service.
#' @export
#' @rdname ci
use_gitlab_ci <- function() {
  check_uses_git()
  new <- use_template(
    "gitlab-ci.yml",
    ".gitlab-ci.yml",
    ignore = TRUE
  )
  if (!new) {
    return(invisible(FALSE))
  }

  invisible(TRUE)
}

#' @section `use_circleci()`:
#' Adds a basic `.circleci/config.yml` to the top-level directory of a package.
#' This is a configuration file for the [CircleCI](https://circleci.com/)
#' continuous integration service.
#' @param image The Docker image to use for build. Must be available on
#'   [DockerHub](https://hub.docker.com). The
#'   [rocker/verse](https://hub.docker.com/r/rocker/verse) image includes
#'   TeXLive, pandoc, and the tidyverse packages. For a minimal image, try
#'   [rocker/r-ver](https://hub.docker.com/r/rocker/r-ver). To specify a version
#'   of R, change the tag from `latest` to the version you want, e.g.
#'   `rocker/r-ver:3.5.3`.
#' @export
#' @rdname ci
use_circleci <- function(browse = rlang::is_interactive(),
                         image = "rocker/verse:latest") {
  repo_spec <- target_repo_spec()
  use_directory(".circleci", ignore = TRUE)
  new <- use_template(
    "circleci-config.yml",
    ".circleci/config.yml",
    data = list(package = project_name(), image = image),
    ignore = TRUE
  )
  if (!new) {
    return(invisible(FALSE))
  }

  use_circleci_badge(repo_spec)
  circleci_activate(spec_owner(repo_spec), browse)

  invisible(TRUE)
}

#' @section `use_circleci_badge()`:
#' Only adds the [Circle CI](https://circleci.com/) badge. Use for a project
#'  where Circle CI is already configured.
#' @rdname ci
#' @export
use_circleci_badge <- function(repo_spec = NULL) {
  repo_spec <- repo_spec %||% target_repo_spec()
  url <- glue("https://circleci.com/gh/{repo_spec}")
  img <- glue("{url}.svg?style=svg")
  use_badge("CircleCI build status", url, img)
}

circleci_activate <- function(owner, browse = is_interactive()) {
  url <- glue("https://circleci.com/add-projects/gh/{owner}")
  ui_todo("Turn on CircleCI for your repo at {url}")
  if (browse) {
    utils::browseURL(url)
  }
}
