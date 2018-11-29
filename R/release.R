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
#' \dontrun{
#' use_release_issue("2.0.0")
#' }
use_release_issue <- function(version) {
  check_uses_github()
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
    todo("`rhub::check(platform = 'solaris-x86-patched')`", has_src),
    todo("`rhub::check(platform = 'ubuntu-rchk')`", has_src),
    todo("`rhub::check_with_sanitizers()", has_src),
    todo("`revdepcheck::revdep_check(num_workers = 4)`", on_cran),
    todo("[Polish NEWS](http://style.tidyverse.org/news.html#before-release)", on_cran),
    todo("Draft blog post", type != "patch"),
    "",
    "Submit to CRAN:",
    "",
    todo("`usethis::use_version('{version}')`"),
    todo("`devtools::check_win_devel()` (again!)"),
    todo("`devtools::submit_cran()`"),
    todo("Approve email"),
    "",
    "Wait for CRAN...",
    "",
    todo("Tag release"),
    todo("`usethis::use_dev_version()`"),
    todo("`usethis::use_news()`", !on_cran),
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

cran_version <- function(package = project_name(),
                         available = utils::available.packages()
                         ) {
  idx <- available[, "Package"] == package
  if (any(idx)) {
    as.package_version(available[package, "Version"])
  } else {
    NULL
  }
}
