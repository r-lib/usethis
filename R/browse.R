#' Quickly browse to important package webpages
#'
#' These functions take you to various webpages associated with a package and
#' return the target URL invisibly. Some URLs are formed from first principles
#' and there is no guarantee there will be content at the destination.

#' @details
#'
#' * `browse_github()`: Looks for a GitHub URL in the URL field of
#' `DESCRIPTION`.
#' * `browse_github_issues()`: Visits the GitHub Issues index or one specific
#' issue.
#' * `browse_github_pulls()`: Visits the GitHub Pull Request index or one
#' specific pull request.
#' * `browse_travis()`: Visits the package's page on [Travis
#' CI](https://travis-ci.com).
#' * `browse_circleci()`: Visits the package's page on [Circle
#' CI](https://circleci.com)
#' * `browse_cran()`: Visits the package on CRAN, via the canonical URL.
#'
#' @param package Name of package; leave as `NULL` to use current package
#' @param number For GitHub issues and pull requests. Can be a number or
#'   `"new"`.
#' @examples
#' browse_github("gh")
#' browse_github_issues("backports")
#' browse_github_issues("backports", 1)
#' browse_github_pulls("rprojroot")
#' browse_github_pulls("rprojroot", 3)
#' browse_travis("usethis")
#' browse_cran("MASS")
#' @name browse-this
NULL

#' @export
#' @rdname browse-this
browse_github <- function(package = NULL) {
  view_url(github_home(package))
}

#' @export
#' @rdname browse-this
browse_github_issues <- function(package = NULL, number = NULL) {
  view_url(github_home(package), "issues", number)
}

#' @export
#' @rdname browse-this
browse_github_pulls <- function(package = NULL, number = NULL) {
  pull <- if (is.null(number)) "pulls" else "pull"
  view_url(github_home(package), pull, number)
}
#' @export
#' @rdname browse-this
browse_github_actions <- function(package = NULL, number = NULL) {
  view_url(github_home(package), "actions", number)
}

#' @export
#' @rdname browse-this
#' @param ext Version of travis to use.
browse_travis <- function(package = NULL, ext = c("com", "org")) {
  gh <- github_home(package)
  ext <- arg_match(ext)
  travis_url <- glue::glue("travis-ci.{ext}")
  view_url(sub("github.com", travis_url, gh))
}

#' @export
#' @rdname browse-this
browse_circleci <- function(package = NULL) {
  gh <- github_home(package)
  circle_url <- "circleci.com/gh"
  view_url(sub("github.com", circle_url, gh))
}

#' @export
#' @rdname browse-this
browse_cran <- function(package = NULL) {
  view_url(cran_home(package))
}

github_url_rx <- function() {
  paste0(
    "^",
    "(?:https?://github.com/)",
    "(?<owner>[^/]+)/",
    "(?<repo>[^/#]+)",
    "/?",
    "(?<fragment>.*)",
    "$"
  )
}

# gets at most one GitHub link from BugReports/URL fields;
# always creates canonical GitHub url, even if the maintainer specified
# something else
github_home <- function(package = NULL) {
  if (is.null(package)) {
    remote <- github_upstream() %||% github_origin()
    if (!is.null(remote)) {
      return(glue("https://github.com/{remote$owner}/{remote$repo}"))
    }

    desc <- desc::desc(proj_get())
    package <- project_name()
  } else {
    desc <- desc::desc(package = package)
  }

  urls <- c(
    desc$get_field("BugReports", default = character()),
    desc$get_urls()
  )
  gh_links <- grep("^https?://github.com/", urls, value = TRUE)

  if (length(gh_links) == 0) {
    ui_warn(c(
      "Package does not provide a GitHub URL.",
      "Falling back to GitHub CRAN mirror"
    ))
    return(glue("https://github.com/cran/{package}"))
  }

  remote <- rematch2::re_match(gh_links[[1]], github_url_rx())
  glue("https://github.com/{remote$owner}/{remote$repo}")
}

cran_home <- function(package = NULL) {
  package <- package %||% project_name()

  glue("https://cran.r-project.org/package={package}")
}
