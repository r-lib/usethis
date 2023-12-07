#' Set up a GitHub Actions workflow
#'
#' @description
#' Sets up continuous integration (CI) for an R package that is developed on
#' GitHub using [GitHub Actions](https://github.com/features/actions). CI can be
#' used to trigger various operations for each push or pull request, e.g.
#' running `R CMD check` or building and deploying a pkgdown site.
#'
#' ## Workflows
#'
#' There are four particularly important workflows that are used by many
#' packages:
#'
#' * `check-standard`: Run `R CMD check` using R-latest on Linux, Mac, and
#'    Windows, and using R-devel and R-oldrel on Linux. This is a good baseline
#'    if you plan on submitting your package to CRAN.
#' * `test-coverage`: Compute test coverage and report to
#'    <https://about.codecov.io> by calling [covr::codecov()].
#' * `pkgdown`: Automatically build and publish a pkgdown website.
#'    But we recommend instead calling [use_pkgdown_github_pages()] which
#'    performs other important set up.
#' * `pr-commands`: Enables the use of two R-specific commands in pull request
#'    issue comments: `/document` to run `roxygen2::roxygenise()` and
#'    `/style` to run `styler::style_pkg()`. Both will update the PR with any
#'    changes once they're done.
#'
#' If you call `use_github_action()` without arguments, you'll be prompted to
#' pick from one of these. Otherwise you can see a complete list of
#' possibilities provided by r-lib at
#' <https://github.com/r-lib/actions/tree/v2/examples>, or you can supply
#' your own `url` to use any other workflow.
#'
#' @param name For `use_github_action()`: Name of one of the example workflow
#'   from <https://github.com/r-lib/actions/tree/v2/examples> (with or
#'   without extension), e.g. `"pkgdown"`, `"check-standard.yaml"`.
#'
#'   If the `name` starts with `check-`, `save_as` will default to
#'   `R-CMD-check.yaml` and `badge` default to `TRUE`.
#' @param ref Desired Git reference, usually the name of a tag (`"v2"`) or
#'   branch (`"main"`). Other possibilities include a commit SHA (`"d1c516d"`)
#'   or `"HEAD"` (meaning "tip of remote's default branch"). If not specified,
#'   defaults to the latest published release of `r-lib/actions`
#'   (<https://github.com/r-lib/actions/releases>).
#' @param url The full URL to a `.yaml` file on GitHub. See more details in
#'   [use_github_file()].
#' @param save_as Name of the local workflow file. Defaults to `name` or
#'   `fs::path_file(url)` for `use_github_action()`. Do not specify any other
#'   part of the path; the parent directory will always be `.github/workflows`,
#'   within the active project.
#' @param readme The full URL to a `README` file that provides more details
#'   about the workflow. Ignored when `url` is `NULL`.
#' @param badge Should we add a badge to the `README`?
#' @inheritParams use_template
#'
#' @examples
#' \dontrun{
#' use_github_action()
#'
#' use_github_action_check_standard()
#'
#' use_github_action("pkgdown")
#' }
#' @export
use_github_action <- function(name = NULL,
                              ref = NULL,
                              url = NULL,
                              save_as = NULL,
                              readme = NULL,
                              ignore = TRUE,
                              open = FALSE,
                              badge = NULL) {

  maybe_name(name)
  maybe_name(ref)
  maybe_name(url)
  maybe_name(save_as)
  maybe_name(readme)
  check_bool(ignore)
  check_bool(open)
  check_bool(badge, allow_null = TRUE)

  if (is.null(url)) {

    name <- name %||% choose_gha_workflow()

    if (path_ext(name) == "") {
      name <- path_ext_set(name, "yaml")
    }

    ref <- ref %||% latest_release()
    url <- glue(
      "https://raw.githubusercontent.com/r-lib/actions/{ref}/examples/{name}"
    )
    readme <- glue(
      "https://github.com/r-lib/actions/blob/{ref}/examples/README.md"
    )
  }

  withr::defer(rstudio_git_tickle())

  use_dot_github(ignore = ignore)

  if (is.null(save_as)) {
    if (is_check_action(url)) {
      save_as <- "R-CMD-check.yaml"
    } else {
      save_as <- path_file(url)
    }
  }

  save_as <- path(".github", "workflows", save_as)
  create_directory(path_dir(proj_path(save_as)))

  if (grepl("^http", url)) {
    # `ignore = FALSE` because we took care of this at directory level, above
    new <- use_github_file(url, save_as = save_as, ignore = FALSE, open = open)
  } else {
    # local file case, https://github.com/r-lib/usethis/issues/1548
    contents <- read_utf8(url)
    new <- write_over(proj_path(save_as), contents)
  }

  if (!is.null(readme)) {
    ui_todo("Learn more at {.url {readme}}.")
  }

  badge <- badge %||% is_check_action(url)
  if (badge) {
    use_github_actions_badge(path_file(save_as))
  }

  invisible(new)
}

choose_gha_workflow <- function(error_call = caller_env()) {
  if (!is_interactive()) {
    cli::cli_abort(
      "{.arg name} is absent and must be supplied",
      call = error_call
    )
  }

  prompt <- cli::format_inline(
    "Which action do you want to add? (0 to exit)\n",
    "(See {.url https://github.com/r-lib/actions/tree/v2/examples} for other options)"
  )
  # Any changes here also need to be reflected in documentation
  workflows <- c(
    "check-standard" = "Run `R CMD check` on Linux, macOS, and Windows",
    "test-coverage" = "Compute test coverage and report to https://about.codecov.io",
    "pr-commands" = "Add /document and /style commands for pull requests"
  )
  options <- paste0(cli::style_bold(names(workflows)), ": ", workflows)

  choice <- utils::menu(
    title = prompt,
    choices = options
  )
  if (choice == 0) {
    cli::cli_abort("Selection terminated", call = error_call)
  }

  names(workflows)[choice]
}

is_check_action <- function(url) {
  grepl("^check-", path_file(url))
}

#' Generates a GitHub Actions badge
#'
#' Generates a GitHub Actions badge and that's all. This exists primarily for
#' internal use.
#'
#' @keywords internal
#' @param name Name of the workflow's YAML configuration file (with or without
#'   extension), e.g. `"R-CMD-check"`, `"R-CMD-check.yaml"`.
#' @inheritParams use_github_action
#' @export
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
#' @inheritParams use_github_action
use_tidy_github_actions <- function(ref = NULL) {
  repo_spec <- target_repo_spec()

  use_github_action("check-full", ref = ref, badge = TRUE)

  use_github_action("pr-commands", ref = ref)
  use_github_action("pkgdown", ref = ref)

  use_coverage(repo_spec = repo_spec)
  use_github_action("test-coverage", ref = ref)

  old_configs <- proj_path(c(".travis.yml", "appveyor.yml"))
  has_appveyor_travis <- file_exists(old_configs)

  if (any(has_appveyor_travis)) {
    if (ui_yeah(
      "Remove existing {ui_path('.travis.yml')} and {ui_path('appveyor.yml')}?"
    )) {
      file_delete(old_configs[has_appveyor_travis])
      # TODO maybe add ui_path("README.Rmd")?
      ui_todo("Remove old badges from README")
    }
  }

  invisible(TRUE)
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

latest_release <- function(repo_spec = "https://github.com/r-lib/actions") {
  parsed <- parse_repo_url(repo_spec)
  # https://docs.github.com/en/rest/reference/releases#list-releases
  raw_releases <- gh::gh(
    "/repos/{owner}/{repo}/releases",
    owner       = spec_owner(parsed$repo_spec),
    repo        = spec_repo(parsed$repo_spec),
    .api_url    = parsed$host,
    .limit = Inf
  )
  tag_names <- purrr::discard(
    map_chr(raw_releases, "tag_name"),
    map_lgl(raw_releases, "prerelease")
  )
  pick_tag(tag_names)
}

# 1) filter to releases in the latest major version series
# 2) return the max, according to R's numeric_version logic
pick_tag <- function(nm) {
  dat <- data.frame(nm = nm, stringsAsFactors = FALSE)
  dat$version <- numeric_version(sub("^[^0-9]*", "", dat$nm))
  dat <- dat[dat$version == max(dat$version), ]
  dat$nm[1]
}
