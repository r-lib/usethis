#' Continuous integration setup and badges
#'
#' @description
#' `r lifecycle::badge("questioning")`
#'
#' These functions are not actively used by the tidyverse team, and may not
#' currently work. Use at your own risk.
#'
#' Sets up third-party continuous integration (CI) services for an R package
#' on GitLab or CircleCI. These functions:
#'
#' * Add service-specific configuration files and add them to `.Rbuildignore`.
#' * Activate a service or give the user a detailed prompt.
#' * Provide the markdown to insert a badge into README.
#'
#' @section `use_gitlab_ci()`:
#' Adds a basic `.gitlab-ci.yml` to the top-level directory of a package. This
#' is a configuration file for the [GitLab
#' CI/CD](https://docs.gitlab.com/ee/ci/) continuous integration service.
#' @export
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
#' @param browse Open a browser window to enable automatic builds for the
#'   package.
#' @param image The Docker image to use for build. Must be available on
#'   [DockerHub](https://hub.docker.com). The
#'   [rocker/verse](https://hub.docker.com/r/rocker/verse) image includes
#'   TeXLive, pandoc, and the tidyverse packages. For a minimal image, try
#'   [rocker/r-ver](https://hub.docker.com/r/rocker/r-ver). To specify a version
#'   of R, change the tag from `latest` to the version you want, e.g.
#'   `rocker/r-ver:3.5.3`.
#' @export
#' @rdname use_gitlab_ci
use_circleci <- function(
  browse = rlang::is_interactive(),
  image = "rocker/verse:latest"
) {
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
#' @rdname use_gitlab_ci
#' @eval param_repo_spec()
#' @export
use_circleci_badge <- function(repo_spec = NULL) {
  repo_spec <- repo_spec %||% target_repo_spec()
  url <- glue("https://circleci.com/gh/{repo_spec}")
  img <- glue("{url}.svg?style=svg")
  use_badge("CircleCI build status", url, img)
}

circleci_activate <- function(owner, browse = is_interactive()) {
  url <- glue("https://circleci.com/add-projects/gh/{owner}")
  ui_bullets(c(
    "_" = "Turn on CircleCI for your repo at {.url {url}}."
  ))
  if (browse) {
    utils::browseURL(url)
  }
}
