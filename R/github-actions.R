#' GitHub Actions setup and badges
#'
#' Sets up continuous integration (CI) for an R package that is developed on
#' GitHub using [GitHub Actions](https://github.com/features/actions). These functions
#' - Add the necessary configuration files and place them in `.Rbuildignore`.
#' - Provide the markdown to insert a badge into your README
#' @name github_actions
#' @seealso [use_github_action()] for setting up a specific action.
NULL

#' @section `use_github_actions()`:
#' Adds a basic `R-CMD-check.yaml` file to the `.github/workflows` directory of a
#'  package. This is a configuration file for the [GitHub
#'  Actions](https://github.com/features/actions) service.
#' @rdname github_actions
#' @export
use_github_actions <- function() {
  check_uses_github()

  use_github_action_check_release()
}

#' @details

#' * `use_tidy_github_actions()`: Sets up the following workflows using [GitHub
#' Actions](https://github.com/features/actions):
#'   - Runs `R CMD check` on the current release, devel, and four previous
#'     versions of R.
#'   - Adds adds two commands to be used in pull requests: `/document` to run
#'     `roxygen2::roxygenise()` and update the PR, and `/style` to run
#'     `styler::style_pkg()` and update the PR.
#'   - Builds a pkgdown site for the package.
#' @rdname tidyverse
#' @export
use_tidy_github_actions <- function() {
  check_uses_github()

  use_coverage()

  full_status    <- use_github_action_check_full()
  pr_status      <- use_github_action_pr_commands()
  pkgdown_status <- use_github_action("pkgdown")
  test_coverage_status <- use_github_action("test-coverage")

  old_configs <- proj_path(c(".travis.yml", "appveyor.yml"))
  has_appveyor_travis <- file_exists(old_configs)

  if (any(has_appveyor_travis)) {
    if (ui_yeah(
      "Remove existing {ui_path('.travis.yml')} and {ui_path('appveyor.yml')}?"
    )) {
      file_delete(old_configs[has_appveyor_travis])
      ui_todo("Remove old badges from README")
    }
  }

  invisible(full_status && pr_status && pkgdown_status && test_coverage_status)
}

#' @section `use_github_actions_badge()`:
#' Only adds the [GitHub Actions](https://github.com/features/actions) badge. Use for a project
#'   where GitHub Actions is already configured.
#' @param name The name to give to the [GitHub
#'   Actions](https://github.com/features/actions) workflow.
#' @export
#' @rdname github_actions
use_github_actions_badge <- function(name = "R-CMD-check") {
  check_uses_github()

  name <- utils::URLencode(name)
  img <- glue("{github_home()}/workflows/{name}/badge.svg")
  url <- glue("{github_home()}/actions")

  use_badge("R build status", url, img)
}

uses_github_actions <- function(base_path = proj_get()) {
  path <- glue("{base_path}/.github/workflows")
  file_exists(path)
}

check_uses_github_actions <- function(base_path = proj_get()) {
  if (uses_github_actions(base_path)) {
    return(invisible())
  }

  ui_stop(
    "
    Cannot detect that package {ui_value(project_name(base_path))} already uses GitHub Actions.
    Do you need to run {ui_code('use_github_actions()')}?
    "
  )
}
