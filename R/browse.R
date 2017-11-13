#' Quickly browse to important package webpages
#'
#' @param package Name of package; leave as `NULL` to use current package
#' @param number For GitHub issues and pull requests. Can be a number or
#'   `"new"`.
#' @export
#' @examples
#' browse_cran("MASS")
browse_github <- function(package = NULL) {
  view_url(github_home(package))
}

#' @export
#' @rdname browse_github
browse_github_issues <- function(package = NULL, number = NULL) {
  view_url(github_home(package), "issues", number)
}

#' @export
#' @rdname browse_github
browse_github_pulls <- function(package = NULL, number = NULL) {
  view_url(github_home(package), "pulls", number)
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

github_home <- function(package = NULL) {
  if (is.null(package)) {
    desc <- desc::desc(proj_get())
  } else {
    desc <- desc::desc(package = package)
  }

  urls <- desc$get_urls()
  gh_links <- grep("^https?://github.com/", urls, value = TRUE)

  if (length(gh_links) == 0) {
    stop("Couldn't find GitHub home", call. = FALSE)
  }

  gh_links[[1]]
}


cran_home <- function(package = NULL) {
  package <- package %||% project_name()

  paste0("https://cran.r-project.org/package=", package)
}
