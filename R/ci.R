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
#' configuration file for the [Travis CI](https://travis-ci.com/) continuous
#' integration service.
#' @param browse Open a browser window to enable automatic builds for the
#'   package.
#' @param ext Which travis website to use. Defaults to `"com"` for
#'   https://travis-ci.com. Change to `"org"` for https://travis-ci.org.
#' @export
#' @rdname ci
use_travis <- function(browse = rlang::is_interactive(), ext = c("com", "org")) {
  check_uses_github()
  ext <- arg_match(ext)
  new <- use_template(
    "travis.yml",
    ".travis.yml",
    ignore = TRUE
  )
  if (!new) {
    return(invisible(FALSE))
  }

  travis_activate(browse, ext = ext)
  use_travis_badge(ext = ext)
  invisible(TRUE)
}

#' @section `use_travis_badge()`:
#' Only adds the [Travis CI](https://travis-ci.com/) badge. Use for a project
#'  where Travis is already configured.
#' @export
#' @rdname ci
use_travis_badge <- function(ext = c("com", "org")) {
  check_uses_github()
  ext <- arg_match(ext)
  url <- glue("https://travis-ci.{ext}/{github_repo_spec()}")
  img <- glue("{url}.svg?branch=master")
  use_badge("Travis build status", url, img)
}

travis_activate <- function(browse = is_interactive(), ext = c("com", "org")) {
  ext <- arg_match(ext)
  url <- glue("https://travis-ci.{ext}/profile/{github_owner()}")

  ui_todo("Turn on travis for your repo at {url}")
  if (browse) {
    utils::browseURL(url)
  }
}

uses_travis <- function(base_path = proj_get()) {
  path <- glue("{base_path}/.travis.yml")
  file_exists(path)
}

check_uses_travis <- function(base_path = proj_get()) {
  if (uses_travis(base_path)) {
    return(invisible())
  }

  ui_stop(
    "
    Cannot detect that package {ui_value(project_name(base_path))} already uses Travis.
    Do you need to run {ui_code('use_travis()')}?
    "
  )
}

#' @section `use_appveyor()`:
#' Adds a basic `appveyor.yml` to the top-level directory of a package. This is
#' a configuration file for the [AppVeyor](https://www.appveyor.com) continuous
#' integration service for Windows.
#' @export
#' @rdname ci
use_appveyor <- function(browse = rlang::is_interactive()) {
  check_uses_github()

  new <- use_template("appveyor.yml", ignore = TRUE)
  if (!new) {
    return(invisible(FALSE))
  }

  appveyor_activate(browse)
  use_appveyor_badge()

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
use_appveyor_badge <- function() {
  appveyor <- appveyor_info()
  use_badge("AppVeyor build status", appveyor$url, appveyor$img)
}

appveyor_info <- function() {
  check_uses_github()
  img <- glue(
    "https://ci.appveyor.com/api/projects/status/github/",
    "{github_repo_spec()}?branch=master&svg=true"
  )
  url <- glue("https://ci.appveyor.com/project/{github_repo_spec()}")

  list(url = url, img = img)
}

#' @section `use_gitlab_ci()`:
#' Adds a basic `.gitlab-ci.yml` to the top-level directory of a package. This is
#' a configuration file for the [GitLab CI/CD](https://docs.gitlab.com/ee/ci/) continuous
#' integration service for GitLab.
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

uses_gitlab_ci <- function(base_path = proj_get()) {
  path <- path(base_path, ".gitlab-ci.yml")
  file_exists(path)
}

check_uses_gitlab_ci <- function(base_path = proj_get()) {
  if (uses_gitlab_ci(base_path)) {
    return(invisible())
  }

  ui_stop(
    "
    Cannot detect that package {ui_value(project_name(base_path))} already uses GitLab CI.
    Do you need to run {ui_code('use_gitlab_ci()')}?
    "
  )
}

#' @section `use_circleci()`:
#' Adds a basic `.circleci/config.yml` to the top-level directory of a package. This is a
#' configuration file for the [CircleCI](https://circleci.com/) continuous
#' integration service.
#' @param image The Docker image to use for build. Must be available on
#'   [DockerHub](https://hub.docker.com). The
#'   [rocker/verse](https://hub.docker.com/r/rocker/verse) image includes TeX
#'   Live, pandoc, and the tidyverse packages. For a minimal image, try
#'   [rocker/r-ver](https://hub.docker.com/r/rocker/r-ver). To specify a version
#'   of R, change the tag from `latest` to the version you want, e.g.
#'   `rocker/r-ver:3.5.3`.
#' @export
#' @rdname ci
use_circleci <- function(browse = rlang::is_interactive(), image = "rocker/verse:latest") {
  check_uses_github()
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

  circleci_activate(browse)
  use_circleci_badge()
  invisible(TRUE)
}

#' @section `use_circleci_badge()`:
#' Only adds the [Circle CI](https://www.circleci.com) badge. Use for a project
#'  where Circle CI is already configured.
#' @export
#' @rdname ci
#' @export
use_circleci_badge <- function() {
  check_uses_github()
  url <- glue("https://circleci.com/gh/{github_repo_spec()}")
  img <- glue("{url}.svg?style=svg")
  use_badge("CircleCI build status", url, img)
}

circleci_activate <- function(browse = is_interactive()) {
  url <- glue("https://circleci.com/add-projects/gh/{github_owner()}")

  ui_todo("Turn on CircleCI for your repo at {url}")
  if (browse) {
    utils::browseURL(url)
  }
}

uses_circleci <- function(base_path = proj_get()) {
  path <- glue("{base_path}/.circleci/config.yml")
  file_exists(path)
}

check_uses_circleci <- function(base_path = proj_get()) {
  if (uses_circleci(base_path)) {
    return(invisible())
  }

  ui_stop(
    "
    Cannot detect that package {ui_field(project_name(base_path))} already uses CircleCI.
    Do you need to run {ui_code('use_circleci()')}?
    "
  )
}
