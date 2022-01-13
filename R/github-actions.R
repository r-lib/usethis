# general GHA setup ------------------------------------------------------------

#' GitHub Actions setup
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

#' * Adds the necessary configuration files and lists them in `.Rbuildignore`
#' * Provides the markdown to insert a badge into your README
#'
#' @name github_actions

#' @param name For `use_github_action()`: Name of one of the example workflows
#'   from <https://github.com/r-lib/actions/tree/v2/examples>. Examples:
#'   "pkgdown", "check-standard.yaml".
#'
#'   For `use_github_actions_badge()`: Name of the workflow's YAML configuration
#'   file. Examples: "R-CMD-check", "R-CMD-check.yaml".
#'
#'   If `name` has no extension, we assume it's `.yaml`.
#' @eval param_repo_spec()
#' @param url The full URL to a `.yaml` file on GitHub.
#' @param save_as Name of the local workflow file. Defaults to `name` or
#'   `fs::path_file(url)` for `use_github_action()`. Do not specify any other
#'   part of the path; the parent directory will always be `.github/workflows`,
#'   within the active project.
#' @param readme The full URL to a `README` file that provides more details
#'   about the workflow. Ignored when `url` is `NULL`.
#' @inheritParams use_template
#'

#' @seealso
#' * [use_github_file()] for more about `url` format and parsing.
#' * [use_tidy_github_actions()] for the standard GitHub Actions used for
#'   tidyverse packages.

#' @examples
#' \dontrun{
#' use_github_actions()
#'
#' use_github_action_check_standard()
#'
#' use_github_action("pkgdown")
#' }
NULL

#' @section `use_github_actions()`:
#' Configures a basic `R CMD check` workflow on GitHub Actions by adding a
#' standard `R-CMD-check.yaml` file to the `.github/workflows` directory of the
#' active project. This is actually just an alias for
#' `use_github_action_check_release()`.
#' @export
#' @rdname github_actions
use_github_actions <- function() {
  use_github_action_check_release()
}

#' @section `use_github_actions_badge()`:
#' Generates a GitHub Actions badge and that's all. It does not configure a
#' workflow. This exists mostly for internal use in the other functions
#' documented here.
#' @export
#' @rdname github_actions
use_github_actions_badge <- function(name = "R-CMD-check.yaml",
                                     repo_spec = NULL) {
  if (path_ext(name) == "") {
    name <- path_ext_set(name, "yaml")
  }
  repo_spec <- repo_spec %||% target_repo_spec()
  enc_name <- utils::URLencode(name)
  img <- glue("https://github.com/{repo_spec}/actions/workflows/{enc_name}/badge.svg")
  url <- glue("https://github.com/{repo_spec}/actions/workflows/{enc_name}")

  use_badge(path_ext_remove(name), url, img)
}

# individual actions -----------------------------------------------------------

#' @section `use_github_action()`:
#' Configures an individual, specific [GitHub
#' Actions](https://github.com/features/actions) workflow, either one of the
#' examples from
#' [r-lib/actions/examples](https://github.com/r-lib/actions/tree/v2/examples)
#' or a custom workflow given by the `url` parameter.
#'
#' Used internally to power all the other GitHub Actions functions, but it can
#' also be called directly by the user.
#' @export
#' @rdname github_actions
use_github_action <- function(name,
                              url = NULL,
                              save_as = NULL,
                              readme = NULL,
                              ignore = TRUE,
                              open = FALSE) {
  if (is.null(url)) {
    check_string(name)
    if (path_ext(name) == "") {
      name <- path_ext_set(name, "yaml")
    }
    url <- glue(
      "https://raw.githubusercontent.com/r-lib/actions/v2/examples/{name}"
    )
    readme <- "https://github.com/r-lib/actions/blob/v2/examples/README.md"
  } else {
    check_string(url)
    maybe_string(readme)
  }
  withr::defer(rstudio_git_tickle())

  use_dot_github(ignore = ignore)

  if (is.null(save_as)) {
    save_as <- path_file(url)
  }
  check_string(save_as)
  save_as <- path(".github", "workflows", save_as)
  create_directory(path_dir(proj_path(save_as)))

  # `ignore = FALSE` because we took care of this at directory level, above
  new <- use_github_file(url, save_as = save_as, ignore = FALSE, open = open)

  if (!is.null(readme)) {
    ui_todo("Learn more at <{readme}>.")
  }

  invisible(new)
}

#' @section `use_github_action_check_release()`:
#' This entry-level, bare-minimum workflow installs the latest release of R (on
#' a current distribution of Linux) and runs `R CMD check` via the
#' [rcmdcheck](https://github.com/r-lib/rcmdcheck) package.
#' @export
#' @rdname github_actions
use_github_action_check_release <- function(save_as = "R-CMD-check.yaml",
                                            ignore = TRUE,
                                            open = FALSE) {
  use_github_action(
    "check-release.yaml",
    save_as = save_as,
    ignore = ignore,
    open = open
  )
  use_github_actions_badge(save_as)
}

#' @section `use_github_action_check_standard()`:
#' This workflow runs `R CMD check` via the
#' [rcmdcheck](https://github.com/r-lib/rcmdcheck) package on the three major
#' operating systems (Linux, macOS, and Windows) on the latest release of R and
#' on R-devel. This workflow is appropriate for a package that is (or aspires to
#' be) on CRAN or Bioconductor.
#' @export
#' @rdname github_actions
use_github_action_check_standard <- function(save_as = "R-CMD-check.yaml",
                                             ignore = TRUE,
                                             open = FALSE) {
  use_github_action(
    "check-standard.yaml",
    save_as = save_as,
    ignore = ignore,
    open = open
  )
  use_github_actions_badge(save_as)
}

#' @section `use_github_action_pr_commands()`:
#' This workflow enables the use of two R-specific commands in pull request
#' issue comments:
#' * `/document` to run `roxygen2::roxygenise()` and update the PR
#' * `/style` to run `styler::style_pkg()` and update the PR
#' @export
#' @rdname github_actions
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

# tidyverse GHA setup ----------------------------------------------------------

#' @details
#' * `use_tidy_github_actions()`: Sets up the following workflows using [GitHub
#' Actions](https://github.com/features/actions):
#'   - Run `R CMD check` on the current release, devel, and four previous
#'     versions of R. The build matrix also ensures `R CMD check` is run at
#'     least once on each of the three major operating systems (Linux, macOS,
#'     and Windows).
#'   - Report test coverage.
#'   - Build and deploy a pkgdown site.
#'   - Provide two commands to be used in pull requests: `/document` to run
#'     `roxygen2::roxygenise()` and update the PR, and `/style` to run
#'     `styler::style_pkg()` and update the PR.
#'
#'     This is how the tidyverse team checks its packages, but it is overkill
#'     for less widely used packages. Consider using the more streamlined
#'     workflows set up by [use_github_actions()] or
#'     [use_github_action_check_standard()].
#' @export
#' @rdname tidyverse
use_tidy_github_actions <- function() {
  repo_spec <- target_repo_spec()

  use_coverage(repo_spec = repo_spec)

  # we killed use_github_action_check_full() because too many people were using
  # it who are better served by something less over-the-top
  # now we inline it here
  full_status <- use_github_action("check-full.yaml", save_as = "R-CMD-check.yaml")
  use_github_actions_badge("R-CMD-check.yaml", repo_spec = repo_spec)

  pr_status <- use_github_action_pr_commands()
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

# GHA helpers ------------------------------------------------------------------

uses_github_actions <- function() {
  path <- proj_path(".github", "workflows")
  file_exists(path)
}

check_uses_github_actions <- function() {
  if (uses_github_actions()) {
    return(invisible())
  }

  ui_stop("
    Cannot detect that package {ui_value(project_name())} already \\
    uses GitHub Actions.
    Do you need to run {ui_code('use_github_actions()')}?")
}
