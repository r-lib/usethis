#' Helpers for the tidyverse
#'
#' These helpers follow tidyverse conventions which are generally a little
#' stricter than the defaults, reflecting the need for greater rigor in
#' commonly used packages.
#'
#' @details
#'
#' * `use_tidy_ci()`: sets up [Travis CI](https://travis-ci.org) and
#' [Codecov](https://codecov.io), ensuring that the package works on all
#' versions of R starting at 3.1.
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
#' @inheritParams use_travis
use_tidy_ci <- function(browse = interactive()) {
  check_uses_github()

  new <- use_template(
    "tidy-travis.yml",
    ".travis.yml",
    ignore = TRUE
  )
  use_template("codecov.yml", ignore = TRUE)

  use_dependency("R", "Depends", ">= 3.1")
  use_dependency("covr", "Suggests")

  use_travis_badge()
  use_codecov_badge()

  if (new) {
    travis_activate(browse)
  }

  invisible(TRUE)
}


#' @export
#' @rdname tidyverse
use_tidy_description <- function() {
  base_path <- proj_get()

  # Alphabetise dependencies
  deps <- desc::desc_get_deps(base_path)
  deps <- deps[order(deps$type, deps$package), , drop = FALSE]
  desc::desc_del_deps(file = base_path)
  desc::desc_set_deps(deps, file = base_path)

  # Alphabetise remotes
  remotes <- desc::desc_get_remotes(file = base_path)
  if (length(remotes) > 0) {
    desc::desc_set_remotes(sort(remotes), file = base_path)
  }

  # Reorder all fields
  desc::desc_reorder_fields(file = base_path)

  invisible(TRUE)
}


#' @export
#' @rdname tidyverse
#' @param overwrite By default (`FALSE`), only dependencies without version
#'   specifications will be modified. Set to `TRUE` to modify all dependencies.
use_tidy_versions <- function(overwrite = FALSE) {
  deps <- desc::desc_get_deps(proj_get())

  baserec <- base_and_recommended()
  to_change <- !deps$package %in% c("R", baserec)
  if (!overwrite) {
    to_change <- to_change & deps$version == "*"
  }

  deps$version[to_change] <- vapply(deps$package[to_change], dep_version, character(1))
  desc::desc_set_deps(deps, file = proj_get())

  invisible(TRUE)
}

is_installed <- function(x) {
  length(find.package(x, quiet = TRUE)) > 0
}
dep_version <- function(x) {
  if (is_installed(x)) paste0(">= ", utils::packageVersion(x)) else "*"
}


#' @export
#' @rdname tidyverse
use_tidy_eval <- function() {
  if (!uses_roxygen()) {
    stop_glue("{code('use_tidy_eval()')} requires that you use roxygen.")
  }

  use_dependency("rlang", "Imports", ">= 0.1.2")
  use_template("tidy-eval.R", "R/utils-tidy-eval.R")

  todo("Run {code('devtools::document()')}")
}


#' @export
#' @rdname tidyverse
use_tidy_contributing <- function() {
  check_uses_github()

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
  check_uses_github()

  use_directory(".github", ignore = TRUE)
  use_template(
    "tidy-issue.md",
    ".github/ISSUE_TEMPLATE.md"
  )
}


#' @export
#' @rdname tidyverse
use_tidy_support <- function() {
  check_uses_github()

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
  check_uses_github()

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
  done("Styled project according to the tidyverse style guide")
  invisible(styled)
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

  res <- gh::gh(
    "/repos/:owner/:repo/issues",
    owner = spec_owner(repo_spec), repo = spec_repo(repo_spec),
    since = from_timestamp,
    state = "all",
    filter = "all",
    .limit = Inf
  )
  if (identical(res[[1]], "")) {
    message("No matching issues/PRs found.")
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
    message("No matching issues/PRs found.")
    return(invisible())
  }

  contributors <- sort(unique(pluck_chr(res, c("user", "login"))))
  todo("{length(contributors)} contributors identified")
  code_block(
    collapse(
      glue("[@{contributors}](https://github.com/{contributors})"),
      sep = ", ", last = ", and "
    )
  )
  invisible(contributors)
}

## if x appears to be a timestamp, pass it through
## otherwise, assume it's a ref and look up its timestamp
as_timestamp <- function(x = NULL, repo_spec = github_repo_spec()) {
  if (is.null(x)) return(NULL)
  as_POSIXct <- try(as.POSIXct(x), silent = TRUE)
  if (inherits(as_POSIXct, "POSIXct")) return(x)
  message("Resolving timestamp for ref ", value(x))
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
  c("base", "boot", "class", "cluster", "codetools", "compiler",
    "datasets", "foreign", "graphics", "grDevices", "grid", "KernSmooth",
    "lattice", "MASS", "Matrix", "methods", "mgcv", "nlme", "nnet",
    "parallel", "rpart", "spatial", "splines", "stats", "stats4",
    "survival", "tcltk", "tools", "utils")
}
