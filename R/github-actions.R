# general GHA setup ------------------------------------------------------------

#' GitHub Actions setup and badges
#'
#' @description
#' Sets up continuous integration (CI) for an R package that is developed on
#' GitHub using [GitHub Actions](https://github.com/features/actions). CI can be
#' used to trigger various operations for each push or pull request, such as:
#' * Run `R CMD check` on various operating systems and R versions
#' * Build and deploy a pkgdown site
#' * Determine test coverage
#'
#' This family of functions
#' * Adds the necessary configuration files and lists them in `.Rbuildignore`.
#' * Provides the markdown to insert a badge into your README.
#'
#' @name github_actions
#' @seealso
#' * [use_github_action()] sets up specific, individual actions, e.g. test
#'   coverage or pkgdown build and deploy.
#' * [use_tidy_github_actions()] sets up the standard GitHub Actions used for
#'   tidyverse packages.
NULL

#' @section `use_github_actions()`:
#' Configures a basic `R CMD check` workflow on GitHub Actions by adding a
#' standard `R-CMD-check.yaml` file to the `.github/workflows` directory of the
#' active project.
#' @rdname github_actions
#' @export
use_github_actions <- function() {
  use_github_action_check_release()
}

#' @section `use_github_actions_badge()`:
#' Generates a GitHub Actions badge and that's all. It does not configure a
#' workflow.
#' @param name Specifies the workflow whose status the badge will report. This
#'   is the `name` keyword that appears in the workflow `.yaml` file.
#' @eval param_repo_spec()
#' @export
#' @rdname github_actions
use_github_actions_badge <- function(name = "R-CMD-check", repo_spec = NULL) {
  repo_spec <- repo_spec %||% target_repo_spec()
  enc_name <- utils::URLencode(name)
  img <- glue("https://github.com/{repo_spec}/workflows/{enc_name}/badge.svg")
  url <- glue("https://github.com/{repo_spec}/actions")

  use_badge(name, url, img)
}

uses_github_actions <- function(base_path = proj_get()) {
  path <- glue("{base_path}/.github/workflows")
  file_exists(path)
}

check_uses_github_actions <- function(base_path = proj_get()) {
  if (uses_github_actions(base_path)) {
    return(invisible())
  }

  ui_stop("
    Cannot detect that package {ui_value(project_name(base_path))} already \\
    uses GitHub Actions.
    Do you need to run {ui_code('use_github_actions()')}?
    ")
}

# tidyverse GHA setup ----------------------------------------------------------

#' @details
#' * `use_tidy_github_actions()`: Sets up the following workflows using [GitHub
#' Actions](https://github.com/features/actions):
#'   - Run `R CMD check` on the current release, devel, and four previous
#'     versions of R.
#'   - Report test coverage.
#'   - Build and deploy a pkgdown site.
#'   - Provide two commands to be used in pull requests: `/document` to run
#'     `roxygen2::roxygenise()` and update the PR, and `/style` to run
#'     `styler::style_pkg()` and update the PR.
#' @rdname tidyverse
#' @export
use_tidy_github_actions <- function() {
  repo_spec <- target_repo_spec()

  use_coverage(repo_spec = repo_spec)

  full_status <- use_github_action_check_full(repo_spec = repo_spec)
  pr_status   <- use_github_action_pr_commands()
  pkgdown_status <- use_github_action("pkgdown-pak", save_as = "pkgdown.yaml")
  test_coverage_status <- use_github_action("test-coverage-pak", save_as = "test-coverage.yaml")

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

# individual actions -----------------------------------------------------------
#' Use a specific GitHub Actions workflow
#'
#' Configure an individual, specific [GitHub
#' Actions](https://github.com/features/actions) workflow, either one of the
#' examples from
#' [r-lib/actions/examples](https://github.com/r-lib/actions/tree/master/examples)
#' or a custom workflow given by the `url` parameter.
#'
#' @inheritParams use_template
#' @param name Name of the workflow file, with or without a `.yaml` extension.
#' @param url The full URL to the `.yaml` file. By default, the corresponding
#'   workflow in <https://github.com/r-lib/actions> will be used.
#' @param save_as Name of the workflow file. Defaults to `fs::path_file(url)`
#'   for `use_github_action()`.
#' @param readme The full URL to a `README` file that provides more details
#'   about the action. Ignored when `url` is `NULL`.
#'
#' @seealso [github_actions] for generic workflows and badge generation.
#'
#' @export
#' @inheritParams use_template
use_github_action <- function(name,
                              url = NULL,
                              save_as = NULL,
                              readme = NULL,
                              ignore = TRUE,
                              open = FALSE) {

  # Check if a custom URL is being used.
  if (is.null(url)) {
    stopifnot(is_string(name))

    # Append a `.yaml` extension if needed
    name <- path_ext_set(name, "yaml")

    url <- glue(
      "https://raw.githubusercontent.com/r-lib/actions/master/examples/{name}"
    )
    readme <- "https://github.com/r-lib/actions/blob/master/examples/README.md"
  } else {
    stopifnot(is_string(url))
  }

  if (is.null(save_as)) {
    save_as <- path_file(url)
  }

  contents <- read_utf8(url)

  use_dot_github(ignore = ignore)

  save_as <- path(".github", "workflows", save_as)
  create_directory(path_dir(proj_path(save_as)))

  new <- write_over(proj_path(save_as), contents)

  if (open && new) {
    edit_file(proj_path(save_as))
  }
  if (!is.null(readme)) {
    ui_todo("Learn more at <{readme}>")
  }

  invisible(new)
}

#' @section `use_github_action_check_release()`:
#' This workflow installs the latest release of R on macOS and runs `R CMD
#' check` via the [rcmdcheck](https://github.com/r-lib/rcmdcheck) package.
#' @rdname use_github_action
#' @export
use_github_action_check_release <- function(save_as = "R-CMD-check.yaml",
                                            ignore = TRUE,
                                            open = FALSE) {
  use_github_action(
    "check-release.yaml",
    save_as = save_as,
    ignore = ignore,
    open = open
  )
  use_github_actions_badge("R-CMD-check")
}

#' @section `use_github_action_check_standard()`:
#' This workflow runs `R CMD check` via the
#' [rcmdcheck](https://github.com/r-lib/rcmdcheck) package on the three major
#' operating systems (linux, macOS, and Windows) on the latest release of R and
#' on R-devel. This workflow is appropriate for a package that is (or will
#' hopefully be) on CRAN or Bioconductor.
#' @rdname use_github_action
#' @export
use_github_action_check_standard <- function(save_as = "R-CMD-check.yaml",
                                             ignore = TRUE,
                                             open = FALSE) {
  use_github_action(
    "check-standard.yaml",
    save_as = save_as,
    ignore = ignore,
    open = open
  )
  use_github_actions_badge("R-CMD-check")
}

#' @section `use_github_action_check_full()`:

#' This workflow runs `R CMD check` at least once on each of the three major
#' operating systems (linux, macOS, and Windows) and on the current release,
#' devel, and four previous versions of R. This is how the tidyverse team checks
#' its packages, but it may be overkill for less widely used packages. Consider
#' using the more streamlined workflows set up by [use_github_actions()] or
#' `use_github_action_check_standard()`.
#' @rdname use_github_action
#' @eval param_repo_spec()
#' @export
use_github_action_check_full <- function(save_as = "R-CMD-check.yaml",
                                         ignore = TRUE,
                                         open = FALSE,
                                         repo_spec = NULL) {
  # this must have `repo_spec` as an argument because it is called as part of
  # use_tidy_github_actions()
  use_github_action(
    "check-pak.yaml",
    save_as = save_as,
    ignore = ignore,
    open = open
  )
  use_github_actions_badge("R-CMD-check", repo_spec = repo_spec)
}

#' @section `use_github_action_pr_commands()`:
#' This workflow enables the use of two R-specific commands in pull request
#' issue comments:
#' * `/document` to run `roxygen2::roxygenise()` and update the PR
#' * `/style` to run `styler::style_pkg()` and update the PR
#' @rdname use_github_action
#' @export
use_github_action_pr_commands <- function(save_as = "pr-commands.yaml",
                                          ignore = TRUE,
                                          open = FALSE) {
  use_github_action(
    "pr-commands.yaml",
    save_as = save_as,
    ignore = ignore,
    open = open
  )
}
