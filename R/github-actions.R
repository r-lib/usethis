#' GitHub Actions setup and badges
#'
#' Sets up continuous integration (CI) for an R package that is developed on
#' GitHub using [GitHub Actions](https://github.com/features/actions). These functions
#' - Add the necessary configuration files and place them in `.Rbuildignore`.
#' - Provide the markdown to insert a badge into your README
#' @name github_actions
NULL

#' @section `use_github_actions()`:
#' Adds a basic ‘R-CMD-check.yaml’ file to the `.github/workflows` directory of a
#'  package. This is a configuration file for the [GitHub
#'  Actions](https://github.com/features/actions) service.
#' @rdname github_actions
#' @export
use_github_actions <- function() {
  check_uses_github()

  use_github_action_check_release()
}

#' @section `use_github_actions_tidy()`:
#' Sets up tidyverse actions that check the R versions officially supported by
#'   the tidyverse, (current release, devel and four previous versions). It also
#'   adds two commands to be used in pull requests, `\document` to run
#'   `roxygen2::roxygenise()` and update the PR, and `\style` to run
#'   `styler::style_pkg()` and update the PR.
#' @rdname github_actions
#' @export
use_github_actions_tidy <- function() {
  check_uses_github()

  new <- use_github_action_check_full() && use_github_action_pr_commands()

  invisible(new)
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
  url <- glue("{github_home()}/actions?workflow={name}")
  img <- glue("{github_home()}/workflows/{name}/badge.svg")

  use_badge("R build status", url, img)
}

#' @section `use_github_action()`:
#' Use a specific action, either one of the example actions from
#'   [r-lib/actions/examples](https://github.com/r-lib/actions/tree/master/examples) or a custom action
#'   given by the `url` parameter.
#' @param url The full URL to the GitHub Actions yaml file.
#' @inheritParams use_template
#' @rdname github_actions
use_github_action <- function(name,
                       url = glue("https://raw.githubusercontent.com/r-lib/actions/master/examples/{name}"),
                       save_as = basename(url),
                       ignore = TRUE,
                       open = FALSE) {
  contents <- readLines(url)

  save_as <- path(".github", "workflows", save_as)

  create_directory(dirname(proj_path(save_as)))
  new <- write_over(proj_path(save_as), contents)

  if (ignore) {
    use_build_ignore(save_as)
  }

  if (open && new) {
    edit_file(proj_path(save_as))
  }

  invisible(new)
}

#' @section `use_github_action_check_release()`:
#' This action installs the latest release R version on macOS and runs `R CMD check`
#'   via the [rcmdcheck](https://github.com/r-lib/rcmdcheck) package.
#' @rdname github_actions
#' @export
use_github_action_check_release <- function(save_as = "R-CMD-check.yaml", ignore = TRUE, open = FALSE) {
  use_github_action("check-release.yaml", save_as = save_as, ignore = ignore, open = open)

  use_github_actions_badge("R-CMD-check")
}

#' @section `use_github_action_check_full()`:
#' This action installs the last 5 minor R versions and runs R CMD check
#'   via the [rcmdcheck](https://github.com/r-lib/rcmdcheck) package on the
#'   three major OSs (linux, macOS and Windows). This action is what the
#'   tidyverse teams uses on their repositories, but is overkill for less
#'   widely used packages, which are better off using the simpler
#'   `use_github_action_check_release()`.
#' @rdname github_actions
#' @export
use_github_action_check_full <- function(save_as = "R-CMD-check.yaml", ignore = TRUE, open = FALSE) {
  use_github_action("check-full.yaml", save_as = save_as, ignore = ignore, open = open)

  use_github_actions_badge("R-CMD-check")
}

#' @section `use_github_action_pr_commands()`:
#' This workflow enables the use of 2 R specific commands in pull request
#'   issue comments. `\document` will use
#'   [roxygen2](https://roxygen2.r-lib.org/) to rebuild the documentation for
#'   the package and commit the result to the pull request. `\style` will use
#'   [styler](https://styler.r-lib.org/) to restyle your package.
#' @rdname github_actions
#' @export
use_github_action_pr_commands <- function(save_as = "pr-commands.yaml", ignore = TRUE, open = FALSE) {
  use_github_action("pr-commands.yaml", save_as = save_as, ignore = ignore, open = open)
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
    Cannot detect that package {ui_value(project_name(base_path))} already uses Github Actions.
    Do you need to run {ui_code('use_github_actions()')}?
    "
  )
}
