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
#' * `use_tidy_dependencies()`: sets up standard dependencies used by all
#'   tidyverse packages (except packages that are designed to be dependency free).
#'
#' * `use_tidy_description()`: puts fields in standard order and alphabetises
#'   dependencies.
#'
#' * `use_tidy_eval()`: imports a standard set of helpers to facilitate
#'   programming with the tidy eval toolkit.
#'
#' * `use_tidy_style()`: styles source code according to the [tidyverse style
#' guide](https://style.tidyverse.org). This function will overwrite files! See
#' below for usage advice.
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
#' Uses the [styler package](https://styler.r-lib.org) package to style all code
#' in a package, project, or directory, according to the [tidyverse style
#' guide](https://style.tidyverse.org).
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
create_tidy_package <- function(path, copyright_holder = NULL) {
  path <- create_package(path, rstudio = TRUE, open = FALSE)
  local_project(path)

  use_testthat()
  use_mit_license(copyright_holder)
  use_tidy_description()

  use_readme_rmd(open = FALSE)
  use_lifecycle_badge("experimental")
  use_cran_badge()

  use_cran_comments(open = FALSE)

  use_tidy_github()
  ui_todo("In the new package, remember to do:")
  ui_todo("{ui_code('use_git()')}")
  ui_todo("{ui_code('use_github()')}")
  ui_todo("{ui_code('use_tidy_github_actions()')}")
  ui_todo("{ui_code('use_pkgdown()')}")

  proj_activate(path)
}

#' @export
#' @rdname tidyverse
#' @usage NULL
use_tidy_ci <- function(...) {
  ui_warn("`use_tidy_ci()` is deprecated; please use `use_tidy_github_actions()` instead")
}

#' @export
#' @rdname tidyverse
use_tidy_description <- function() {
  desc <- desc::description$new(file = proj_get())
  tidy_desc(desc)
  desc$write()

  ui_todo("Run {ui_code('devtools::document()')} to update package docs")
  invisible(TRUE)
}

#' @export
#' @rdname tidyverse
use_tidy_dependencies <- function() {
  check_has_package_doc("use_tidy_dependencies()")

  use_dependency("rlang", "Imports")
  use_dependency("ellipsis", "Imports")
  use_dependency("lifecycle", "Imports")
  use_dependency("cli", "Imports")
  use_dependency("glue", "Imports")
  use_dependency("withr", "Imports")


  # standard imports
  imports <- any(
    roxygen_ns_append("@import rlang"),
    roxygen_ns_append("@importFrom glue glue"),
    roxygen_ns_append("@importFrom lifecycle deprecated")
  )
  if (imports) {
    roxygen_update_ns()
  }

  # add badges; we don't need the details
  ui_silence(use_lifecycle())


  # If needed, copy in lightweight purrr compatibility layer
  if (!desc::desc(proj_get())$has_dep("purrr")) {
    use_directory("R")
    url <- "https://raw.githubusercontent.com/r-lib/rlang/master/R/compat-purrr.R"
    path <- file_temp()
    utils::download.file(url, path, quiet = TRUE)
    write_over("R/compat-purrr.R", read_utf8(path))
  }

  invisible()
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
  use_dot_github()
  data <- list(
    Package = project_name(),
    github_spec = target_repo_spec(ask = FALSE)
  )
  use_template(
    "tidy-contributing.md",
    path(".github", "CONTRIBUTING.md"),
    data = data
  )
}

#' @export
#' @rdname tidyverse
use_tidy_support <- function() {
  use_dot_github()
  data <- list(
    Package = project_name(),
    github_spec = target_repo_spec(ask = FALSE)
  )
  use_template(
    "tidy-support.md",
    path(".github", "SUPPORT.md"),
    data = data
  )
}


#' @export
#' @rdname tidyverse
use_tidy_issue_template <- function() {
  use_dot_github()
  use_directory(path(".github", "ISSUE_TEMPLATE"))
  use_template(
    "tidy-issue.md",
    path(".github", "ISSUE_TEMPLATE", "issue_template.md")
  )
}

#' @export
#' @rdname tidyverse
use_tidy_coc <- function() {
  use_dot_github()
  use_code_of_conduct("codeofconduct@rstudio.com", path = ".github")
}

#' @export
#' @rdname tidyverse
use_tidy_github <- function() {
  use_dot_github()
  use_tidy_contributing()
  use_tidy_issue_template()
  use_tidy_support()
  use_tidy_coc()
}

use_dot_github <- function(ignore = TRUE) {
  use_directory(".github", ignore = ignore)
  use_git_ignore("*.html", directory = ".github")
}

#' @export
#' @rdname tidyverse
use_tidy_style <- function(strict = TRUE) {
  check_installed("styler")
  challenge_uncommitted_changes(msg = "
    There are uncommitted changes and it is highly recommended to get into a \\
    clean Git state before restyling your project's code")
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
  ui_line()
  ui_done("Styled project according to the tidyverse style guide")
  invisible(styled)
}

#' Identify contributors via GitHub activity
#'
#' Derives a list of GitHub usernames, based on who has opened issues or pull
#' requests. Used to populate the acknowledgment section of package release blog
#' posts at <https://www.tidyverse.org/blog/>. If no arguments are given, we
#' retrieve all contributors to the active project since its last (GitHub)
#' release. Unexported helper functions, `releases()` and `ref_df()` can be
#' useful interactively to get a quick look at release tag names and a data
#' frame about refs (defaulting to releases), respectively.
#'
#' @param repo_spec Optional GitHub repo specification in any form accepted for
#'   the `repo_spec` argument of [create_from_github()] (plain spec or a browser
#'   or Git URL). A URL specification is the only way to target a GitHub host
#'   other than `"github.com"`, which is the default.
#' @param from,to GitHub ref (i.e., a SHA, tag, or release) or a timestamp in
#'   ISO 8601 format, specifying the start or end of the interval of interest,
#'   in the sense of `[from, to]`. Examples: "08a560d", "v1.3.0",
#'   "2018-02-24T00:13:45Z", "2018-05-01". When `from = NULL, to = NULL`, we set
#'   `from` to the timestamp of the most recent (GitHub) release. Otherwise,
#'   `NULL` means "no bound".
#'
#' @return A character vector of GitHub usernames, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' # active project, interval = since the last release
#' use_tidy_thanks()
#'
#' # active project, interval = since a specific datetime
#' use_tidy_thanks(from = "2020-07-24T00:13:45Z")
#'
#' # r-lib/usethis, interval = since a certain date
#' use_tidy_thanks("r-lib/usethis", from = "2020-08-01")
#'
#' # r-lib/usethis, up to a specific release
#' use_tidy_thanks("r-lib/usethis", from = NULL, to = "v1.1.0")
#'
#' # r-lib/usethis, since a specific commit, up to a specific date
#' use_tidy_thanks("r-lib/usethis", from = "08a560d", to = "2018-05-14")
#'
#' # r-lib/usethis, but with copy/paste of a browser URL
#' use_tidy_thanks("https://github.com/r-lib/usethis")
#' }
use_tidy_thanks <- function(repo_spec = NULL,
                            from = NULL,
                            to = NULL) {
  repo_spec <- repo_spec %||% target_repo_spec()
  parsed_repo_spec <- parse_repo_url(repo_spec)
  repo_spec <- parsed_repo_spec$repo_spec
  # this is the most practical way to propagate `host` to downstream helpers
  if (!is.null(parsed_repo_spec$host)) {
    withr::local_envvar(c(GITHUB_API_URL = parsed_repo_spec$host))
  }

  if (is.null(to)) {
    from <- from %||% releases(repo_spec)[[1]]
  }

  from_timestamp <- as_timestamp(repo_spec, x = from) %||% "2008-01-01"
  to_timestamp <- as_timestamp(repo_spec, x = to)
  ui_done("
    Looking for contributors from {as.Date(from_timestamp)} to \\
    {to_timestamp %||% 'now'}")

  res <- gh::gh(
    "/repos/{owner}/{repo}/issues",
    owner = spec_owner(repo_spec), repo = spec_repo(repo_spec),
    since = from_timestamp,
    state = "all",
    filter = "all",
    .limit = Inf
  )
  if (length(res) < 1) {
    ui_oops("No matching issues/PRs found")
    return(invisible())
  }

  creation_time <- function(x) {
    as.POSIXct(map_chr(x, "created_at"))
  }

  res <- res[creation_time(res) >= as.POSIXct(from_timestamp)]

  if (!is.null(to_timestamp)) {
    res <- res[creation_time(res) <= as.POSIXct(to_timestamp)]
  }
  if (length(res) == 0) {
    ui_line("No matching issues/PRs found.")
    return(invisible())
  }

  contributors <- sort(unique(map_chr(res, c("user", "login"))))
  contrib_link <- glue("[&#x0040;{contributors}](https://github.com/{contributors})")

  ui_done("Found {length(contributors)} contributors:")
  ui_code_block(glue_collapse(contrib_link, sep = ", ", last = ", and ") + glue("."))

  invisible(contributors)
}

## if x appears to be a timestamp, pass it through
## otherwise, assume it's a ref and look up its timestamp
as_timestamp <- function(repo_spec, x = NULL) {
  if (is.null(x)) {
    return(NULL)
  }
  as_POSIXct <- try(as.POSIXct(x), silent = TRUE)
  if (inherits(as_POSIXct, "POSIXct")) {
    return(x)
  }
  ui_done("Resolving timestamp for ref {ui_value(x)}")
  ref_df(repo_spec, refs = x)$timestamp
}

## returns a data frame on GitHub refs, defaulting to all releases
ref_df <- function(repo_spec, refs = NULL) {
  stopifnot(is_string(repo_spec))
  refs <- refs %||% releases(repo_spec)
  if (is.null(refs)) {
    return(NULL)
  }
  get_thing <- function(thing) {
    gh::gh(
      "/repos/{owner}/{repo}/commits/{thing}",
      owner = spec_owner(repo_spec), repo = spec_repo(repo_spec),
      thing = thing
    )
  }
  res <- lapply(refs, get_thing)
  data.frame(
    ref = refs,
    sha = substr(map_chr(res, "sha"), 1, 7),
    timestamp = map_chr(res, c("commit", "committer", "date")),
    stringsAsFactors = FALSE
  )
}

## returns character vector of release tag names
releases <- function(repo_spec) {
  stopifnot(is_string(repo_spec))
  res <- gh::gh(
    "/repos/{owner}/{repo}/releases",
    owner = spec_owner(repo_spec), repo = spec_repo(repo_spec)
  )
  if (length(res) < 1) {
    return(NULL)
  }
  map_chr(res, "tag_name")
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
