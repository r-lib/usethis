#' Quickly browse to important package webpages
#'
#' @param package Name of package; leave as `NULL` to use current package
#' @param number For GitHub issues and pull requests. Can be a number or
#'   `"new"`.
#' @export
#' @examples
#' browse_cran("MASS")
browse_github <- function(package = NULL) {
  view_url(github_link(package))
}

#' @export
#' @rdname browse_github
browse_github_issues <- function(package = NULL, number = NULL) {
  view_url(github_home(package), "issues", number)
}

#' @export
#' @rdname browse_github
browse_github_pulls <- function(package = NULL, number = NULL) {
  pull <- if (is.null(number)) "pulls" else "pull"
  view_url(github_home(package), pull, number)
}

#' @export
#' @rdname browse_github
browse_travis <- function(package = NULL) {
  gh <- github_home(package)
  view_url(sub("github.com", "travis-ci.org", gh))
}

#' @export
#' @rdname browse_github
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
    stop("Package does not provide a GitHub URL", call. = FALSE)
  }

  gsub("/$", "", gh_links[[1]])
}

cran_home <- function(package = NULL) {
  package <- package %||% project_name()

  paste0("https://cran.r-project.org/package=", package)
}

github_url_rx <- function() {
  paste0(
    "^",
    "(?:https?://github.com/)",
    "(?<username>[^/]+)/",
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
  file.path("https://github.com", df$username, df$repo)
}
