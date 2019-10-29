#' GitHub Actions setup and badges
#'
#' Sets up continuous integration (CI) for an R package that is developed on
#' GitHub using [GitHub Actions](https://github.com/features/actions). These functions
#' - Add the necessary configuration files and place them in `.Rbuildignore`.
#' - Provide the markdown to insert a badge into your README
#' @name actions
NULL

#' @section `use_github_actions()`:
#' Adds a basic ‘r.yaml’ file to the `.github/workflows` directory of a
#'  package. This is a configuration file for the GitHub Actions service'
#' @rdname actions
#' @export
use_github_actions <- function() {
  check_uses_github()

  new <- use_action_ci_quick()

  if (!new) {
    return(invisible(FALSE))
  }
  use_github_actions_badge("R")

  invisible(TRUE)
}

#' @section `use_tidy_actions()`
#' Sets up tidyverse actions that support the officially supported R versions
#'   (current release, devel and four previous versions). It also adds two
#'   commands to be used in pull requests, `\document` to run
#'   `roxygen2::roxygenise()` and update the PR, and `\style` to run
#'   `styler::style_pkg()` and update the PR.
#' @export
use_tidy_actions <- function() {
  check_uses_github()

  new <- use_action_ci_full() && use_action_pr_commands()

  if (!new) {
    return(invisible(FALSE))
  }

  use_github_actions_badge("R")

  invisible(TRUE)
}

#' @section `use_github_actions_badge()`:
#' Only adds the [GitHub Actions](https://github.com/features/actions) badge. Use for a project
#'   where GitHub actions is already configured.
#' @param name The name to give to the GitHub Actions workflow
#' @export
#' @rdname actions
use_github_actions_badge <- function(name = "R") {
  check_uses_github()

  name <- utils::URLencode(name)
  url <- glue("{github_home()}/actions?workflow={name}")
  img <- glue("{github_home()}/workflows/{name}/badge.svg")

  use_badge("R build status", url, img)
}

#' @section `use_action()`:
#' Use a specific action, either one of the example actions from
#'   [r-lib/actions/examples](https://github.com/r-lib/actions/tree/master/examples) or a custom action
#'   given by the `url` parameter.
#' @param url The full URL to the action yaml file.
#' @inheritParams use_template
#' @rdname actions
use_action <- function(name,
                       url = glue("https://raw.githubusercontent.com/r-lib/actions/master/examples/{name}"),
                       save_as = basename(url),
                       ignore = TRUE,
                       open = FALSE) {
  contents <- readLines(url)

  save_as <- path(".github", "workflows", save_as)

  new <- write_over(proj_path(save_as), contents)

  if (ignore) {
    use_build_ignore(save_as)
  }

  if (open && new) {
    edit_file(proj_path(save_as))
  }

  invisible(new)
}

#' @rdname actions
#' @export
use_action_ci_quick <- function(save_as = "R.yaml", ignore = TRUE, open = FALSE) {
  use_action("ci-quick.yaml", save_as = save_as, ignore = ignore, open = open)
}

#' @rdname actions
#' @export
use_action_ci_full <- function(save_as = "R.yaml", ignore = TRUE, open = FALSE) {
  use_action("ci-full.yaml", save_as = save_as, ignore = ignore, open = open)
}

#' @rdname actions
#' @export
use_action_pr_commands <- function(save_as = "pr-commands.yaml", ignore = TRUE, open = FALSE) {
  use_action("pr-commands.yaml", save_as = save_as, ignore = ignore, open = open)
}
