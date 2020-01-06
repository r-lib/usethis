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
#' * `browse_circleci()`: Visits the package's page on [Circle
#' CI](https://circleci.com)
#' * `browse_cran()`: Visits the package on CRAN, via the canonical URL.
#' * `browse_active_file()`: Open the active file on Github.
#'
#' @param package Name of package; leave as `NULL` to use current package
#' @param number For GitHub issues and pull requests. Can be a number or
#'   `"new"`.
#' @param branch Which branch to use. Defaults to "master" branch.
#' @examples
#' browse_github("gh")
#' browse_github_issues("backports")
#' browse_github_issues("backports", 1)
#' browse_github_pulls("rprojroot")
#' browse_github_pulls("rprojroot", 3)
#' browse_travis("usethis")
#' browse_cran("MASS")
#' \dontrun{
#' browse_active_file()
#' }
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
#' @param ext Version of travis to use.
browse_travis <- function(package = NULL, ext = c("org", "com")) {
  gh <- github_home(package)
  ext <- rlang::arg_match(ext)
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

#' @export
#' @rdname browse-this
browse_active_file <- function(branch = NULL) {
  if (Sys.getenv("RSTUDIO") != 1) {
    stop("Only supported in RStudio.")
  }
  gh_link <- github_link()
  df <- re_match_inline(gh_link, github_url_rx())
  file <- stringr::str_split(rstudioapi::getSourceEditorContext()$path,
    pattern = glue("{df$repo}/"), simplify = TRUE
  )[2]
  if (!is.null(branch)) {
    branch <- branch
  } else {
    branch <- git_branch_name()
  }
  view_url(glue("https://github.com/{df$owner}/{df$repo}/tree/{branch}/{file}"))
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
    ui_warn("
      Package does not provide a GitHub URL.
      Falling back to GitHub CRAN mirror")
    return(glue("https://github.com/cran/{package}"))
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
  df <- re_match_inline(gh_link, github_url_rx())
  glue("https://github.com/{df$owner}/{df$repo}")
}

## inline a simplified version of rematch2::re_match()
re_match_inline <- function(text, pattern) {
  match <- regexpr(pattern, text, perl = TRUE)
  start <- as.vector(match)
  length <- attr(match, "match.length")
  end <- start + length - 1L

  matchstr <- substring(text, start, end)
  matchstr[ start == -1 ] <- NA_character_

  res <- data.frame(
    stringsAsFactors = FALSE,
    .text = text,
    .match = matchstr
  )

  if (!is.null(attr(match, "capture.start"))) {
    gstart <- attr(match, "capture.start")
    glength <- attr(match, "capture.length")
    gend <- gstart + glength - 1L

    groupstr <- substring(text, gstart, gend)
    groupstr[ gstart == -1 ] <- NA_character_
    dim(groupstr) <- dim(gstart)

    res <- cbind(groupstr, res, stringsAsFactors = FALSE)
  }

  names(res) <- c(attr(match, "capture.names"), ".text", ".match")
  res
}
