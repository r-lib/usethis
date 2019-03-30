#' Create a release issue checklist
#'
#' When preparing to release a package there are quite a few steps that
#' need to be performed, and some of the steps can take multiple hours.
#' This function creates an issue checklist so that you can keep track of
#' where you are in the process, and feel a sense of satisfaction as you
#' progress. It also helps watchers of your package stay informed about where
#' you are in the process.
#'
#' @param version Version number for release
#' @export
#' @examples
#' \dontrun{
#' use_release_issue("2.0.0")
#' }
use_release_issue <- function(version = NULL) {
  check_uses_github()
  check_is_package("use_release_issue()")

  version <- version %||% choose_version()
  if (is.null(version)) {
    return(invisible(FALSE))
  }

  checklist <- release_checklist(version)

  issue <- gh::gh("POST /repos/:owner/:repo/issues",
    owner = github_owner(),
    repo = github_repo(),
    title = glue("Release {project_name()} {version}"),
    body = paste(checklist, "\n", collapse = "")
  )

  view_url(issue$html_url)
}

release_checklist <- function(version) {
  type <- release_type(version)
  on_cran <- !is.null(cran_version())
  has_src <- dir_exists(proj_path("src"))

  todo <- function(x, cond = TRUE) {
    x <- glue(x, .envir = parent.frame())
    if (cond) {
      paste0("* [ ] ", x)
    }
  }
  c(
    "Prepare for release:",
    "",
    todo("Check that description is informative", !on_cran),
    todo("Check licensing of included files", !on_cran),
    todo("`usethis::use_cran_comments()`", !on_cran),
    todo("`devtools::check()`"),
    todo("`devtools::check_win_devel()`"),
    todo("`rhub::check_for_cran()`"),
    todo("`rhub::check(platform = 'ubuntu-rchk')`", has_src),
    todo("`rhub::check_with_sanitizers()`", has_src),
    todo("`revdepcheck::revdep_check(num_workers = 4)`", on_cran),
    todo("[Polish NEWS](https://style.tidyverse.org/news.html#news-release)", on_cran),
    todo("Polish pkgdown reference index"),
    todo("Draft blog post", type != "patch"),
    "",
    "Submit to CRAN:",
    "",
    todo("`usethis::use_version('{type}')`"),
    todo("Update `cran-comments.md`"),
    todo("`devtools::submit_cran()`"),
    todo("Approve email"),
    "",
    "Wait for CRAN...",
    "",
    todo("Accepted :tada:"),
    todo("`usethis::use_github_release()`"),
    todo("`usethis::use_dev_version()`"),
    todo("`usethis::use_news()`", !on_cran),
    todo("Update install instructions in README", !on_cran),
    todo("Finish blog post", type != "patch"),
    todo("Tweet"),
    todo("Add link to blog post in pkgdown news menu", type != "patch")
  )
}

release_type <- function(version) {
  x <- unclass(numeric_version(version))[[1]]
  n <- length(x)
  if (n >= 3 && x[[3]] != 0L) {
    "patch"
  } else if (n >= 2 && x[[2]] != 0L) {
    "minor"
  } else {
    "major"
  }
}

#' Draft a GitHub release
#'
#' Creates a __draft__ GitHub release for the current package using the current
#' version and `NEWS.md`. If you are comfortable that it is correct, you will
#' need to publish the release from GitHub. It also deletes `CRAN-RELEASE`
#' and checks that you've pushed all commits to GitHub.
#'
#' @inheritParams use_github_links
#' @export
use_github_release <- function(host = NULL,
                               auth_token = github_token()) {
  cran_release <- proj_path("CRAN-RELEASE")
  if (file_exists(cran_release)) {
    file_delete(cran_release)
  }

  check_uses_github()
  check_branch_pushed()
  check_github_token(auth_token)

  package <- package_data()

  release <- gh::gh(
    "POST /repos/:owner/:repo/releases",
    owner = github_owner(),
    repo = github_repo(),
    tag_name = paste0("v", package$Version),
    name = paste0(package$Package, " ", package$Version),
    body = news_latest(),
    draft = TRUE,
    .api_url = host,
    .token = auth_token
  )

  view_url(release$html_url)
}


cran_version <- function(package = project_name(),
                         available = utils::available.packages()) {
  idx <- available[, "Package"] == package
  if (any(idx)) {
    as.package_version(available[package, "Version"])
  } else {
    NULL
  }
}


news_latest <- function() {
  path <- proj_path("NEWS.md")
  if (!file_exists(path)) {
    ui_stop("{ui_path(path)} not found")
  }

  lines <- readLines(path)
  headings <- which(grepl("^#\\s+", lines))

  if (length(headings == 1)) {
    if (length(headings) == 0) {
      ui_stop("No top-level headings found in {ui_value(path)}")
    } else if (length(headings) == 1) {
      news <- lines[seq2(headings + 1, length(lines))]
    } else {
      news <- lines[seq2(headings[[1]] + 1, headings[[2]] - 1)]
    }
  }

  # Remove leading and trailing empty lines
  text <- which(news != "")
  news <- news[text[[1]]:text[[length(text)]]]

  paste(news, "\n", collapse = "")
}
