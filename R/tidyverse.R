#' Helpers for tidyverse development
#'
#' These helpers follow tidyverse conventions which are generally a little
#' stricter than the defaults, reflecting the need for greater rigor in
#' commonly used packages.
#'
#' @details
#'
#' * `create_tidy_package()`: creates a new package, immediately applies as many
#' of the tidyverse conventions as possible, issues a few reminders, and
#' activates the new package.
#'
#' * `use_tidy_ci()`: sets up [Travis CI](https://travis-ci.org) and
#' [Codecov](https://codecov.io), ensuring that the package works on all
#' versions of R starting at 3.1. It also ignores `compat-` and `deprec-`
#' files from code coverage.
#'
#' * `use_tidy_description()`: puts fields in standard order and alphabetises
#'   dependencies.
#'
#' * `use_tidy_eval()`: imports a standard set of helpers to facilitate
#'   programming with the tidy eval toolkit.
#'
#' * `use_tidy_style()`: styles source code according to the [tidyverse style
#' guide](http://style.tidyverse.org). This function will overwrite files! See
#' below for usage advice.
#'
#' * `use_tidy_versions()`: pins all dependencies to require at least
#'   the currently installed version.
#'
#' * `use_tidy_contributing()`: adds standard tidyverse contributing guidelines.
#'
#' * `use_tidy_issue_template()`: adds a standard tidyverse issue template.
#'
#' * `use_tidy_release_test_env()`: updates the test environment section in
#'   `cran-comments.md`.
#'
#' * `use_tidy_support()`: adds a standard description of support resources for
#'    the tidyverse.
#'
#' * `use_tidy_coc()`: equivalent to `use_code_of_conduct()`, but puts the
#'    document in a `.github/` subdirectory.
#'
#' * `use_tidy_github()`: convenience wrapper that calls
#' `use_tidy_contributing()`, `use_tidy_issue_template()`, `use_tidy_support()`,
#' `use_tidy_coc()`.
#'
#' @section `use_tidy_style()`:
#' Uses the [styler package](http://styler.r-lib.org) package to style all code
#' in a package, project, or directory, according to the [tidyverse style
#' guide](http://style.tidyverse.org).
#'
#' **Warning:** This function will overwrite files! It is strongly suggested to
#' only style files that are under version control or to first create a backup
#' copy.
#'
#' Invisibly returns a data frame with one row per file, that indicates whether
#' styling caused a change.
#'
#' @param strict Boolean indicating whether or not a strict version of styling
#'   should be applied. See [styler::tidyverse_style()] for details.
#'
#' @name tidyverse
NULL

#' @export
#' @rdname tidyverse
#' @inheritParams create_package
#' @inheritParams licenses
create_tidy_package <- function(path,
                                name = "RStudio") {
  path <- create_package(path, rstudio = TRUE, open = FALSE)
  old_project <- proj_set(path)
  on.exit(proj_set(old_project), add = TRUE)

  use_roxygen_md()
  use_testthat()
  use_gpl3_license(name)
  use_tidy_description()

  use_readme_rmd(open = FALSE)
  use_lifecycle_badge("experimental")
  use_cran_badge()
  use_cran_comments(open = FALSE)

  use_tidy_github()
  ui_todo("In the new package, remember to do:")
  ui_todo("{ui_code('use_git()')}")
  ui_todo("{ui_code('use_github()')}")
  ui_todo("{ui_code('use_tidy_ci()')}")
  ui_todo("{ui_code('use_pkgdown()')}")
  ui_todo("{ui_code('use_pkgdown_travis()')}")

  proj_activate(path)
}

#' @export
#' @rdname tidyverse
#' @inheritParams use_travis
use_tidy_ci <- function(browse = interactive()) {
  check_uses_github()

  new_travis <- use_template(
    "tidy-travis.yml",
    ".travis.yml",
    ignore = TRUE
  )
  use_template("codecov.yml", ignore = TRUE)

  use_dependency("R", "Depends", min_version = "3.1")
  use_dependency("covr", "Suggests")
  use_covr_ignore(c("R/deprec-*.R", "R/compat-*.R"))

  use_travis_badge()
  use_codecov_badge()
  use_tidy_release_test_env()

  if (new_travis) {
    travis_activate(browse)
  }

  invisible(TRUE)
}

#' @export
#' @rdname tidyverse
use_tidy_description <- function() {
  desc <- desc::description$new(file = proj_get())
  tidy_desc(desc)
  desc$write()
  invisible(TRUE)
}

#' @export
#' @rdname tidyverse
#' @param overwrite By default (`FALSE`), only dependencies without version
#'   specifications will be modified. Set to `TRUE` to modify all dependencies.
#' @param source Use "local" or "CRAN" package versions.
use_tidy_versions <- function(overwrite = FALSE, source = c("local", "CRAN")) {
  deps <- desc::desc_get_deps(proj_get())
  deps <- update_versions(deps, overwrite = overwrite, source = source)
  desc::desc_set_deps(deps, file = proj_get())

  invisible(TRUE)
}

update_versions <- function(deps, overwrite = FALSE, source = c("local", "CRAN")) {
  baserec <- base_and_recommended()
  to_change <- !deps$package %in% c("R", baserec)
  if (!overwrite) {
    to_change <- to_change & deps$version == "*"
  }

  packages <- deps$package[to_change]
  versions <- switch(match.arg(source),
    local = purrr::map_chr(packages, package_version),
    CRAN = utils::available.packages()[packages, "Version"]
  )
  deps$version[to_change] <- paste0(">= ", versions)

  deps
}

package_version <- function(x) {
  as.character(utils::packageVersion(x))
}

#' @export
#' @rdname tidyverse
use_tidy_eval <- function() {
  check_is_package("use_tidy_eval()")

  use_dependency("roxygen2", "Suggests")
  use_dependency("rlang", "Imports", min_version = "0.1.2")
  new <- use_template("tidy-eval.R", "R/utils-tidy-eval.R")

  ui_todo("Run {ui_code('devtools::document()')}")
  return(invisible(new))
}


#' @export
#' @rdname tidyverse
use_tidy_contributing <- function() {
  use_directory(".github", ignore = TRUE)
  use_template(
    "tidy-contributing.md",
    ".github/CONTRIBUTING.md",
    data = list(package = project_name())
  )
}


#' @export
#' @rdname tidyverse
use_tidy_issue_template <- function() {
  use_directory(".github", ignore = TRUE)
  use_template(
    "tidy-issue.md",
    ".github/ISSUE_TEMPLATE.md"
  )
}


#' @export
#' @rdname tidyverse
use_tidy_support <- function() {
  use_directory(".github", ignore = TRUE)
  use_template(
    "tidy-support.md",
    ".github/SUPPORT.md",
    data = list(package = project_name())
  )
}


#' @export
#' @rdname tidyverse
use_tidy_coc <- function() {
  use_code_of_conduct(path = ".github")
}

#' @export
#' @rdname tidyverse
use_tidy_github <- function() {
  use_tidy_contributing()
  use_tidy_issue_template()
  use_tidy_support()
  use_tidy_coc()
}

#' @export
#' @rdname tidyverse
use_tidy_style <- function(strict = TRUE) {
  check_installed("styler")
  check_uncommitted_changes()
  if (is_package()) {
    styled <- styler::style_pkg(
      proj_get(),
      style = styler::tidyverse_style,
      strict = strict
    )
  } else {
    styled <- styler::style_dir(
      proj_get(),
      style = styler::tidyverse_style,
      strict = strict
    )
  }
  cat_line()
  ui_done("Styled project according to the tidyverse style guide")
  invisible(styled)
}

#' @export
#' @rdname tidyverse
use_tidy_release_test_env <- function() {
  block_replace(
    "release environment",
    tidy_release_test_env(),
    path = proj_path("cran-comments.md"),
    block_start = "## Test environments",
    block_end = "## R CMD check results"
  )
}

tidy_release_test_env <- function() {
  use_bullet <- function(name, versions) {
    versions <- paste(versions, collapse = ", ")
    glue("* {name}: {versions}")
  }

  c(
    "",
    use_bullet("local", paste0(R.version$os, "-", R.version$major, ".", R.version$minor)),
    use_bullet("travis", c("3.1", "3.2", "3.3", "oldrel", "release", "devel")),
    use_bullet("r-hub", c("windows-x86_64-devel", "ubuntu-gcc-release", "fedora-clang-devel")),
    use_bullet("win-builder", "windows-x86_64-devel"),
    ""
  )
}

#' Identify contributors via GitHub activity
#'
#' Derives a list of GitHub usernames, based on who has opened issues or pull
#' requests. Used to populate the acknowledgment section of package release blog
#' posts at <https://www.tidyverse.org/articles/>. All arguments can potentially
#' be determined from the active project, if the project follows standard
#' practices around the GitHub remote and GitHub releases. Unexported helper
#' functions, `releases()` and `ref_df()` can be useful interactively to get a
#' quick look at release tag names and a data frame about refs (defaulting to
#' releases), respectively.
#'
#' @param repo_spec GitHub repo specification in this form: `owner/repo`.
#'   Default is to infer from Git remotes of active project.
#' @param from,to GitHub ref (i.e., a SHA, tag, or release) or a timestamp in
#'   ISO 8601 format, specifying the start or end of the interval of interest.
#'   Examples: "08a560d", "v1.3.0", "2018-02-24T00:13:45Z", "2018-05-01". `NULL`
#'   means there is no bound on that end of the interval.
#'
#' @return A character vector of GitHub usernames, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' ## active project, interval = since the last release
#' use_tidy_thanks()
#'
#' ## active project, interval = since a specific datetime
#' use_tidy_thanks(from = "2018-02-24T00:13:45Z")
#'
#' ## r-lib/usethis, inteval = since a certain date
#' use_tidy_thanks("r-lib/usethis", from = "2018-05-01")
#'
#' ## r-lib/usethis, up to a specific release
#' use_tidy_thanks("r-lib/usethis", from = NULL, to = "v1.3.0")
#'
#' ## r-lib/usethis, since a specific commit, up to a specific date
#' use_tidy_thanks("r-lib/usethis", from = "08a560d", to = "2018-05-14")
#' }
use_tidy_thanks <- function(repo_spec = github_repo_spec(),
                            from = releases(repo_spec)[[1]],
                            to = NULL) {
  from_timestamp <- as_timestamp(from, repo_spec) %||% "2008-01-01"
  to_timestamp <- as_timestamp(to, repo_spec)
  ui_done("Looking for contributors from {as.Date(from_timestamp)} to {to_timestamp %||% 'now'}")

  res <- gh::gh(
    "/repos/:owner/:repo/issues",
    owner = spec_owner(repo_spec), repo = spec_repo(repo_spec),
    since = from_timestamp,
    state = "all",
    filter = "all",
    .limit = Inf
  )
  if (identical(res[[1]], "")) {
    ui_line("No matching issues/PRs found.")
    return(invisible())
  }

  creation_time <- function(x) {
    as.POSIXct(pluck_chr(x, "created_at"))
  }

  res <- res[creation_time(res) >= as.POSIXct(from_timestamp)]

  if (!is.null(to_timestamp)) {
    res <- res[creation_time(res) <= as.POSIXct(to_timestamp)]
  }
  if (length(res) == 0) {
    ui_line("No matching issues/PRs found.")
    return(invisible())
  }

  contributors <- sort(unique(pluck_chr(res, c("user", "login"))))
  contrib_link <- glue("[&#x0040;{contributors}](https://github.com/{contributors})")

  ui_done("Found {length(contributors)} contributors:")
  ui_code_block(glue_collapse(contrib_link, sep = ", ", last = ", and "))

  invisible(contributors)
}

## if x appears to be a timestamp, pass it through
## otherwise, assume it's a ref and look up its timestamp
as_timestamp <- function(x = NULL, repo_spec = github_repo_spec()) {
  if (is.null(x)) return(NULL)
  as_POSIXct <- try(as.POSIXct(x), silent = TRUE)
  if (inherits(as_POSIXct, "POSIXct")) return(x)
  ui_line("Resolving timestamp for ref ", ui_value(x))
  ref_df(x, repo_spec)$timestamp
}

## returns a data frame on GitHub refs, defaulting to all releases
ref_df <- function(refs = NULL, repo_spec = github_repo_spec()) {
  refs <- refs %||% releases(repo_spec)
  if (is.null(refs)) return(NULL)
  get_thing <- function(thing) {
    gh::gh(
      "/repos/:owner/:repo/commits/:thing",
      owner = spec_owner(repo_spec), repo = spec_repo(repo_spec), thing = thing
    )
  }
  res <- lapply(refs, get_thing)
  data.frame(
    ref = refs,
    sha = substr(pluck_chr(res, "sha"), 1, 7),
    timestamp = pluck_chr(res, c("commit", "committer", "date")),
    stringsAsFactors = FALSE
  )
}

## returns character vector of release tag names
releases <- function(repo_spec = github_repo_spec()) {
  res <- gh::gh(
    "/repos/:owner/:repo/releases",
    owner = spec_owner(repo_spec),
    repo = spec_repo(repo_spec)
  )
  if (identical(res[[1]], "")) return(NULL)
  pluck_chr(res, "tag_name")
}

## approaches based on available.packages() and/or installed.packages() present
## several edge cases, requirements, and gotchas
## for this application, hard-wiring seems to be "good enough"
base_and_recommended <- function() {
  # base_pkgs <- as.vector(installed.packages(priority = "base")[, "Package"])
  # av <- available.packages()
  # keep <- av[ , "Priority", drop = TRUE] %in% "recommended"
  # rec_pkgs <- unname(av[keep, "Package", drop = TRUE])
  # dput(sort(unique(c(base_pkgs, rec_pkgs))))
  c(
    "base", "boot", "class", "cluster", "codetools", "compiler",
    "datasets", "foreign", "graphics", "grDevices", "grid", "KernSmooth",
    "lattice", "MASS", "Matrix", "methods", "mgcv", "nlme", "nnet",
    "parallel", "rpart", "spatial", "splines", "stats", "stats4",
    "survival", "tcltk", "tools", "utils"
  )
}
