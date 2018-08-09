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
#' CI](https://travis-ci.org).
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
  view_url(github_link(package))
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
browse_travis <- function(package = NULL) {
  gh <- github_home(package)
  view_url(sub("github.com", "travis-ci.org", gh))
}

#' @export
#' @rdname browse-this
browse_cran <- function(package = NULL) {
  view_url(cran_home(package))
}

## gets at most one GitHub link from the URL field of DESCRIPTION
## strips any trailing slash
## respects the URL given by maintainer, e.g.
## "https://github.com/simsem/semTools/wiki" <-- note the "wiki" part
## "https://github.com/r-lib/gh#readme" <-- note trailing "#readme"
github_link <- function(package = NULL) {
  if (is.null(package)) {
    desc <- desc::desc(proj_get())
  } else {
    desc <- desc::desc(package = package)
  }

  urls <- desc$get_urls()
  gh_links <- grep("^https?://github.com/", urls, value = TRUE)

  if (length(gh_links) == 0) {
    stop_glue("Package does not provide a GitHub URL.")
  }

  gsub("/$", "", gh_links[[1]])
}

cran_home <- function(package = NULL) {
  package <- package %||% project_name()

  glue("https://cran.r-project.org/package={package}")
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

## takes URL return by github_link() and strips it down to support
## appending path parts for issues or pull requests
##  input: "https://github.com/simsem/semTools/wiki"
## output: "https://github.com/simsem/semTools"
##  input: "https://github.com/r-lib/gh#readme"
## output: "https://github.com/r-lib/gh"
github_home <- function(package = NULL) {
  gh_link <- github_link(package)
  df <- rematch2::re_match(gh_link, github_url_rx())
  glue("https://github.com/{df$owner}/{df$repo}")
}
