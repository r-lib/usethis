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
#' @param ext which travis website to use. default to `"org"`for
#'   https://travis-ci.org. Change to `"com"` for https://travis-ci.com.
#' @export
#' @rdname ci
use_travis <- function(browse = interactive(), ext = c("org", "com")) {
  check_uses_github()
  ext <- rlang::arg_match(ext)
  new <- use_template(
    "travis.yml",
    ".travis.yml",
    ignore = TRUE
  )
  if (!new) return(invisible(FALSE))

  travis_activate(browse, ext = ext)
  use_travis_badge(ext = ext)
  invisible(TRUE)
}

#' @section `use_travis_badge()`:
#' Only adds the [Travis CI](https://travis-ci.org/) badge. Use for a project
#'  where Travis is already configured.
#' @export
#' @rdname ci
use_travis_badge <- function(ext = "org") {
  check_uses_github()
  url <- glue("https://travis-ci.{ext}/{github_repo_spec()}")
  img <- glue("{url}.svg?branch=master")
  use_badge("Travis build status", url, img)
}

travis_activate <- function(browse = interactive(), ext = "org") {
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
use_appveyor <- function(browse = interactive()) {
  check_uses_github()

  new <- use_template("appveyor.yml", ignore = TRUE)
  if (!new) return(invisible(FALSE))

  appveyor_activate(browse)
  use_appveyor_badge()

  invisible(TRUE)
}

appveyor_activate <- function(browse = interactive()) {
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
  if (!new) return(invisible(FALSE))

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
use_circleci <- function(browse = interactive(), image = "rocker/verse:latest") {
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

use_circleci_badge <- function() {
  check_uses_github()
  url <- glue("https://circleci.com/gh/{github_repo_spec()}")
  img <- glue("{url}.svg?style=svg")
  use_badge("CircleCI build status", url, img)
}

circleci_activate <- function(browse = interactive()) {
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

#' @section `use_azure_pipelines()`:
#' Adds a basic `azure-pipelines.yml` to the top-level directory of a package. This is
#' a configuration file for the [Azure Pipelines](https://azure.microsoft.com/en-us/services/devops/pipelines/) continuous
#' integration service.
#' @export
#' @rdname ci
use_azure_pipelines <- function(browse = interactive()) {
  check_uses_github()
  new <- use_template(
    "azure-pipelines.yml",
    "azure-pipelines.yml",
    ignore = TRUE
  )

  use_dependency("xml2", "Suggests")
  use_directory(path("tests", "testthat"))
  use_template(
    "junit-testthat.R",
    save_as = path("tests", "testthat.R"),
    data = list(name = project_name())
  )
  azure_activate(browse)
  use_azure_badge()
  use_azure_test_badge()

  use_dependency("covr", "Suggests")
  use_azure_coverage_badge()

  invisible(TRUE)
}

azure_activate <- function(browse = interactive(), ext = "org") {
  url <- glue("https://github.com/{github_repo_spec()}/settings/installations")

  ui_todo("Setup a azure project for your repo by configuring the Azure Pipeline GitHub App at {url}")
  if (browse) {
    utils::browseURL(url)
  }
}

use_azure_badge <- function() {
  check_uses_github()
  url <- glue("https://dev.azure.com/{github_repo_spec()}/_build/latest?definitionId=1&branchName=master")
  img <- glue("https://img.shields.io/azure-devops/build/{github_repo_spec()}/2")
  use_badge("Azure pipelines build status", url, img)
}

use_azure_test_badge <- function() {
  check_uses_github()
  url <- glue("https://dev.azure.com/{github_repo_spec()}/_build/latest?definitionId=1&branchName=master")
  img <- glue("https://img.shields.io/azure-devops/tests/{github_repo_spec()}/2?color=brightgreen&compact_message")
  use_badge("Azure pipelines test status", url, img)
}

use_azure_coverage_badge <- function() {
  check_uses_github()
  url <- glue("https://dev.azure.com/{github_repo_spec()}/_build/latest?definitionId=1&branchName=master")
  img <- glue("https://img.shields.io/azure-devops/coverage/{github_repo_spec()}/2")
  use_badge("Azure pipelines coverage status", url, img)
}
