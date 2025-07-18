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
#' * [use_tidy_github_labels()] calls `use_github_labels()` to implement
#'   tidyverse conventions around GitHub issue label names and colours.
#'
#' * `use_tidy_upkeep_issue()` creates an issue containing a checklist of
#'   actions to bring your package up to current tidyverse standards. Also
#'   records the current date in the `Config/usethis/last-upkeep` field in
#'   `DESCRIPTION`.
#'
#' * `use_tidy_logo()` calls `use_logo()` on the appropriate hex sticker PNG
#'   file at <https://github.com/rstudio/hex-stickers>.
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

  ui_bullets(c("i" = "In the new package, remember to do:"))
  ui_code_snippet(
    "
    usethis::use_git()
    usethis::use_github()
    usethis::use_tidy_github()
    usethis::use_tidy_github_actions()
    usethis::use_tidy_github_labels()
    usethis::use_pkgdown_github_pages()
  "
  )

  proj_activate(path)
}


#' @export
#' @rdname tidyverse
use_tidy_description <- function() {
  desc <- proj_desc()
  tidy_desc(desc)
  desc$write()

  invisible(TRUE)
}

#' @export
#' @rdname tidyverse
use_tidy_dependencies <- function() {
  check_has_package_doc("use_tidy_dependencies()")

  use_dependency("rlang", "Imports")
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
  if (!proj_desc()$has_dep("purrr")) {
    use_directory("R")
    use_standalone("r-lib/rlang", "purrr")
  }

  invisible()
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
  old_top_level_coc <- proj_path(c("CODE_OF_CONDUCT.md", "CONDUCT.md"))
  old <- file_exists(old_top_level_coc)
  if (any(old)) {
    file_delete(old_top_level_coc[old])
  }

  use_dot_github()
  use_coc(contact = "codeofconduct@posit.co", path = ".github")
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
use_tidy_thanks <- function(repo_spec = NULL, from = NULL, to = NULL) {
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
  ui_bullets(c(
    "i" = "Looking for contributors from {as.Date(from_timestamp)} to
           {to_timestamp %||% 'now'}."
  ))

  res <- gh::gh(
    "/repos/{owner}/{repo}/issues",
    owner = spec_owner(repo_spec),
    repo = spec_repo(repo_spec),
    since = from_timestamp,
    state = "all",
    filter = "all",
    .limit = Inf
  )
  if (length(res) < 1) {
    ui_bullets(c("x" = "No matching issues/PRs found."))
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
    ui_bullets(c("x" = "No matching issues/PRs found."))
    return(invisible())
  }

  contributors <- sort(unique(map_chr(res, c("user", "login"))))
  contrib_link <- glue(
    "[&#x0040;{contributors}](https://github.com/{contributors})"
  )

  ui_bullets(c("v" = "Found {length(contributors)} contributors:"))
  ui_code_snippet(
    glue_collapse(contrib_link, sep = ", ", last = ", and ") + glue("."),
    language = ""
  )

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
  ui_bullets(c("v" = "Resolving timestamp for ref {.val {x}}."))
  ref_df(repo_spec, refs = x)$timestamp
}

## returns a data frame on GitHub refs, defaulting to all releases
ref_df <- function(repo_spec, refs = NULL) {
  check_name(repo_spec)
  check_character(refs, allow_null = TRUE)
  refs <- refs %||% releases(repo_spec)
  if (is.null(refs)) {
    return(NULL)
  }
  get_thing <- function(thing) {
    gh::gh(
      "/repos/{owner}/{repo}/commits/{thing}",
      owner = spec_owner(repo_spec),
      repo = spec_repo(repo_spec),
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
  check_name(repo_spec)
  res <- gh::gh(
    "/repos/{owner}/{repo}/releases",
    owner = spec_owner(repo_spec),
    repo = spec_repo(repo_spec)
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
    "base",
    "boot",
    "class",
    "cluster",
    "codetools",
    "compiler",
    "datasets",
    "foreign",
    "graphics",
    "grDevices",
    "grid",
    "KernSmooth",
    "lattice",
    "MASS",
    "Matrix",
    "methods",
    "mgcv",
    "nlme",
    "nnet",
    "parallel",
    "rpart",
    "spatial",
    "splines",
    "stats",
    "stats4",
    "survival",
    "tcltk",
    "tools",
    "utils"
  )
}

#' @rdname tidyverse
#' @inheritParams use_logo
#' @export
use_tidy_logo <- function(geometry = "240x278", retina = TRUE) {
  if (!is_posit_pkg()) {
    ui_abort("This function only works for Posit packages.")
  }

  tf <- withr::local_tempfile(fileext = ".png")

  gh::gh(
    "/repos/rstudio/hex-stickers/contents/PNG/{pkg}.png/",
    pkg = project_name(),
    .destfile = tf,
    .accept = "application/vnd.github.v3.raw"
  )

  use_logo(tf, geometry = geometry, retina = retina)
}
