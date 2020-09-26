#' Visit important project-related web pages
#'
#' These functions take you to various web pages associated with a project
#' (here, usually a package) and return the target URL invisibly. To form
#' these URLs we consult:
#' * Git remotes configured for the active project that are associated with
#'   github.com
#' * DESCRIPTION file for the active project or the specified `package`
#' * Fixed templates:
#'   - Travis CI: `https://travis-ci.{EXT}/{OWNER}/{PACKAGE}`
#'   - Circle CI: `https://circleci.com/gh/{OWNER}/{PACKAGE}`
#'   - CRAN landing page: `https://cran.r-project.org/package={PACKAGE}`
#'   - GitHub mirror of a CRAN package: `https://github.com/cran/{PACKAGE}`
#'   Templated URLs aren't checked for existence, so there is no guarantee
#'   there will be content at the destination.
#'
#' @details
#' * `browse_github()`: Visits a GitHub repository associated with the project.
#'   In the case of a fork, you might be asked to specify if you're interested
#'   in the parent repo or your fork.
#' * `browse_github_issues()`: Visits the GitHub Issues index or one specific
#'   issue.
#' * `browse_github_pulls()`: Visits the GitHub Pull Request index or one
#'   specific pull request.
#' * `browse_travis()`: Visits the project's page on
#'   [Travis CI](https://travis-ci.com).
#' * `browse_circleci()`: Visits the project's page on
#'   [Circle CI](https://circleci.com).
#' * `browse_cran()`: Visits the package on CRAN, via the canonical URL.
#'
#' @param package Name of package. If `NULL`, inferred from the active project.
#' @param number Optional, to specify an individual GitHub issue or pull
#'   request. Can be a number or `"new"`.
#'
#' @examples
#' browse_github("gh")
#' browse_github_issues("fs")
#' browse_github_issues("fs", 1)
#' browse_github_pulls("curl")
#' browse_github_pulls("curl", 183)
#' browse_travis("gert", ext = "org")
#' browse_cran("MASS")
#' @name browse-this
NULL

#' @export
#' @rdname browse-this
browse_github <- function(package = NULL) {
  view_url(github_url(package))
}

#' @export
#' @rdname browse-this
browse_github_issues <- function(package = NULL, number = NULL) {
  view_url(github_url(package), "issues", number)
}

#' @export
#' @rdname browse-this
browse_github_pulls <- function(package = NULL, number = NULL) {
  pull <- if (is.null(number)) "pulls" else "pull"
  view_url(github_url(package), pull, number)
}
#' @export
#' @rdname browse-this
browse_github_actions <- function(package = NULL) {
  view_url(github_url(package), "actions")
}

#' @export
#' @rdname browse-this
#' @param ext Version of travis to use.
browse_travis <- function(package = NULL, ext = c("com", "org")) {
  gh <- github_url(package)
  ext <- arg_match(ext)
  travis_url <- glue::glue("travis-ci.{ext}")
  view_url(sub("github.com", travis_url, gh))
}

#' @export
#' @rdname browse-this
browse_circleci <- function(package = NULL) {
  gh <- github_url(package)
  circle_url <- "circleci.com/gh"
  view_url(sub("github.com", circle_url, gh))
}

#' @export
#' @rdname browse-this
browse_cran <- function(package = NULL) {
  view_url(cran_home(package))
}

# Try to get a GitHub repo spec from these places:
# 1. Remotes associated with github.com (active project)
# 2. BugReports/URL fields of DESCRIPTION (active project or arbitrary
#    installed package)
github_url <- function(package = NULL) {
  if (is.null(package)) {
    repo_spec <- target_repo_spec()
    if (!is.null(repo_spec)) {
      return(glue("https://github.com/{repo_spec}"))
    }
  }
  if (is.null(package)) {
    desc <- desc::desc(file = proj_get())
  } else {
    desc <- desc::desc(package = package)
  }
  remote <- github_remote_from_description(desc)
  if (is.null(remote)) {
    ui_warn("
      Can't discover a GitHub URL.
      Falling back to GitHub CRAN mirror")
    glue("https://github.com/cran/{package %||% project_name()}")
  } else {
    glue("https://github.com/{remote$repo_owner}/{remote$repo_name}")
  }
}

cran_home <- function(package = NULL) {
  package <- package %||% project_name()

  glue("https://cran.r-project.org/package={package}")
}
