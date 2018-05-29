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
    stop("`use_tidy_eval()` requires that you use roxygen.", call. = FALSE)
  }

  use_dependency("rlang", "Imports", ">= 0.1.2")
  use_template("tidy-eval.R", "R/utils-tidy-eval.R")

  todo("Run document()")
}


#' @export
#' @rdname tidyverse
use_tidy_contributing <- function() {
  check_uses_github()

  use_directory(".github", ignore = TRUE)
  use_template(
    "tidy-contributing.md",
    ".github/CONTRIBUTING.md",
    data = list(
      package = project_name()
    )
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
#' practices around the GitHub remote and GitHub releases.
#'
#' @param owner Name of user or organisation who owns the repo. Default is to
#'   infer from Git remotes of active project.
#' @param repo Repository name, usually same as package name. Default is to
#'   infer from Git remotes of active project.
#' @param since Timestamp in ISO 8601 format, passed along to the [GitHub API
#'   endpoint for listing
#'   issues](https://developer.github.com/v3/issues/#list-issues-for-a-repository).
#'    Default is to use timestamp of commit associated with most recent GitHub
#'   release.
#'
#' @return A character vector of GitHub usernames, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' use_tidy_thanks()
#' use_tidy_thanks(owner = "r-lib", repo = "usethis")
#' use_tidy_thanks(owner = "r-lib", repo = "usethis", since = "2018-05-01")
#' use_tidy_thanks(since = "2018-02-24T00:13:45Z")
#' }
use_tidy_thanks <- function(owner = NULL,
                            repo = NULL,
                            since = NULL) {
  if (is.null(owner) || is.null(repo)) {
    check_uses_github()
    gh <- gh::gh_tree_remote(proj_get())
    owner <- owner %||% gh$username
    repo <- repo %||% gh$repo
  }

  if (is.null(since)) {
    releases <- report_releases(owner, repo)
    if (is.null(releases)) {
      ## GitHub was founded later in 2008
      since <- "2008-01-01"
      message("No GitHub releases found. ", code("since"), " will be unset.")
    } else {
      since <- releases$commit_date
      message(
        "Setting ", code("since"), " based on most recent GitHub release:\n",
        "* Release name: ", releases$name, "\n",
        "* Tag name: ", releases$tag_name, "\n",
        "* SHA: ", releases$sha, "\n",
        "* Commit date: ", releases$commit_date, " <-- effective value of ",
        code("since"), "\n"
      )
    }
  }

  res <- gh::gh(
    "/repos/:owner/:repo/issues",
    owner = owner, repo = repo,
    since = since,
    state = "all",
    .limit = Inf
  )
  if (identical(res[[1]], "")) {
    message("No contributors found.")
    return(invisible())
  }

  contributors <- sort(
    unique(
      vapply(res, function(x) x[["user"]][["login"]], character(1))
    )
  )
  todo(length(contributors), " contributors identified")
  code_block(
    glue::glue_collapse(
      glue::glue("[\\@{contributors}](https://github.com/{contributors})"),
      ", ", last = ", and "
    )
  )
  invisible(contributors)
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

## returns a data frame on up to n recent GitHub releases
## helps the user set `since` in use_tidy_thanks()
report_releases <- function(owner = "r-lib", repo = "usethis", n = 1) {
  ## minimalist purrr::pluck()
  f <- function(l, what) vapply(l, `[[`, character(1), what)

  res <- gh::gh(
    "/repos/:owner/:repo/releases",
    owner = owner, repo = repo
  )
  if (identical(res[[1]], "")) {
    return(NULL)
  }
  res <- utils::head(res, min(n, length(res)))
  releases <- data.frame(
    tag_name = f(res, "tag_name"),
    name = f(res, "name"),
    stringsAsFactors = FALSE
  )

  get_sha <- function(ref) {
    gh::gh(
      "/repos/:owner/:repo/commits/:ref",
      owner = owner, repo = repo, ref = ref,
      .send_headers = c("Accept" = "application/vnd.github.VERSION.sha")
    )[["message"]]
  }
  releases$sha <- substr(vapply(releases$tag_name, get_sha, character(1)), 1, 7)

  get_when <- function(sha) {
    gh::gh(
      "/repos/:owner/:repo/commits/:sha",
      owner = owner, repo = repo, sha = sha
    )[[c("commit", "committer", "date")]]
  }
  releases$commit_date <- vapply(releases$sha, get_when, character(1))

  releases
}
