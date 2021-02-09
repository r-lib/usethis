#' Create a release checklist in a GitHub issue
#'
#' When preparing to release a package there are quite a few steps that need to
#' be performed, and some of the steps can take multiple hours. This function
#' creates an issue checklist so that you can keep track of where you are in the
#' process, and feel a sense of satisfaction as you progress. It also helps
#' watchers of your package stay informed about where you are in the process.
#'
#' @param version Optional version number for release. If unspecified, you can
#'   make an interactive choice.
#' @export
#' @examples
#' \dontrun{
#' use_release_issue("2.0.0")
#' }
use_release_issue <- function(version = NULL) {
  check_is_package("use_release_issue()")
  tr <- target_repo(github_get = TRUE)
  if (!isTRUE(tr$can_push)) {
    ui_line("
      It is very unusual to open a release issue on a repo you can't push to:
        {ui_value(tr$repo_spec)}")
    if (ui_nope("Do you really want to do this?")) {
      ui_stop("Aborting.")
    }
  }

  version <- version %||% choose_version("What should the release version be?")
  if (is.null(version)) {
    return(invisible(FALSE))
  }

  on_cran <- !is.null(cran_version())
  checklist <- release_checklist(version, on_cran)

  gh <- gh_tr(tr)
  issue <- gh(
    "POST /repos/{owner}/{repo}/issues",
    title = glue("Release {project_name()} {version}"),
    body = paste0(checklist, "\n", collapse = "")
  )

  view_url(issue$html_url)
}

release_checklist <- function(version, on_cran) {
  type <- release_type(version)
  cran_results <- cran_results_url()
  has_src <- dir_exists(proj_path("src"))
  has_news <- file_exists(proj_path("NEWS.md"))
  has_pkgdown <- uses_pkgdown()
  has_readme <- file_exists(proj_path("README.Rmd"))
  has_extra <- exists("release_bullets", parent.env(globalenv()))

  todo <- function(x, cond = TRUE) {
    x <- glue(x, .envir = parent.frame())
    if (cond) {
      paste0("* [ ] ", x)
    }
  }
  c(
    if (!on_cran) c(
      "First release:",
      "",

      todo("`usethis::use_cran_comments()`"),
      todo("Proof read `Title:` and `Description:`"),
      todo("Check that all exported functions have `@returns` and `@examples`"),
      todo("Check that `Authors@R:` includes a copyright holder (role 'cph')"),
      todo("Check [licensing of included files](https://r-pkgs.org/license.html#code-you-bundle)"),
      todo("Review <https://github.com/DavisVaughan/extrachecks>"),
      ""
    ),

    "Prepare for release:",
    "",

    todo("Check [current CRAN check results]({cran_results})", on_cran),

    todo("[Polish NEWS](https://style.tidyverse.org/news.html#news-release)", on_cran),
    todo("`devtools::build_readme()`", has_readme),

    todo("[`urlchecker::url_check()`](https://github.com/r-lib/urlchecker)"),
    todo("`devtools::check(remote = TRUE, manual = TRUE)`"),
    todo("`devtools::check_win_devel()`"),
    todo("`rhub::check_for_cran()`"),
    todo("`rhub::check(platform = 'ubuntu-rchk')`", has_src),
    todo("`rhub::check_with_sanitizers()`", has_src),
    todo("`revdepcheck::revdep_check(num_workers = 4)`", on_cran),

    if (on_cran) todo("Update `cran-comments.md`"),
    todo("Review pkgdown reference index for, e.g., missing topics", has_pkgdown && type != "patch"),
    todo("Draft blog post", type != "patch"),
    if (has_extra) paste0("* [ ] ", get("release_bullets", parent.env(globalenv()))()),
    "",
    "Submit to CRAN:",
    "",
    todo("`usethis::use_version('{type}')`"),
    todo("`devtools::submit_cran()`"),
    todo("Approve email"),
    "",
    "Wait for CRAN...",
    "",
    todo("Accepted :tada:"),
    todo("`usethis::use_github_release()`"),
    todo("`usethis::use_news_md()`", !has_news),
    todo("`usethis::use_dev_version()`"),
    todo("Update install instructions in README", !on_cran),
    todo("Finish blog post", type != "patch"),
    todo("Tweet", type != "patch"),
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
#' need to publish the release from GitHub. It also deletes `CRAN-RELEASE` and
#' checks that you've pushed all commits to GitHub.
#'
#' @param host,auth_token `r lifecycle::badge("deprecated")`: No longer consulted
#'   now that usethis allows the gh package to lookup a token based on a URL
#'   determined from the current project's GitHub remotes.
#' @export
use_github_release <- function(host = deprecated(),
                               auth_token = deprecated()) {
  if (lifecycle::is_present(host)) {
    deprecate_warn_host("use_github_release")
  }
  if (lifecycle::is_present(auth_token)) {
    deprecate_warn_auth_token("use_github_release")
  }

  tr <- target_repo(github_get = TRUE)
  if (!isTRUE(tr$can_push)) {
    ui_stop("
      You don't seem to have push access for {ui_value(tr$repo_spec)}, which \\
      is required to draft a release.")
  }

  challenge_non_default_branch(
    "Are you sure you want to create a release on a non-default branch?"
  )
  check_branch_pushed()

  cran_release <- proj_path("CRAN-RELEASE")
  if (file_exists(cran_release)) {
    file_delete(cran_release)
  }

  path <- proj_path("NEWS.md")
  if (file_exists(path)) {
    news <- news_latest(read_utf8(path))
  } else {
    news <- "Initial release"
  }

  package <- package_data()

  gh <- gh_tr(tr)
  release <- gh(
    "POST /repos/{owner}/{repo}/releases",
    tag_name = paste0("v", package$Version),
    target_commitish = gert::git_info(repo = git_repo())$commit,
    name = paste0(package$Package, " ", package$Version),
    body = news, draft = TRUE
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

cran_results_url <- function(package = project_name()) {
  glue("https://cran.rstudio.org/web/checks/check_results_{package}.html")
}

news_latest <- function(lines) {
  headings <- which(grepl("^#\\s+", lines))

  if (length(headings) == 0) {
    ui_stop("No top-level headings found in {ui_value('NEWS.md')}")
  } else if (length(headings) == 1) {
    news <- lines[seq2(headings + 1, length(lines))]
  } else {
    news <- lines[seq2(headings[[1]] + 1, headings[[2]] - 1)]
  }

  # Remove leading and trailing empty lines
  text <- which(news != "")
  if (length(text) == 0) {
    return("")
  }

  news <- news[text[[1]]:text[[length(text)]]]

  paste0(news, "\n", collapse = "")
}
