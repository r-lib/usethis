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
    Cannot detect that package {ui_(project_name(base_path))} already uses Travis.
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
#' a configuration file for the [Gitlab CI/CD](https://docs.gitlab.com/ee/ci/) continuous
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
    Cannot detect that package {ui_(project_name(base_path))} already uses GitLab CI.
    Do you need to run {ui_code('use_gitlab_ci()')}?
    "
  )
}
