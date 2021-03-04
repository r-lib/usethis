#' Create a release checklist in a GitHub issue
#'
#' @description
#' When preparing to release a package to CRAN there are quite a few steps that
#' need to be performed, and some of the steps can take multiple hours. This
#' function creates a checklist in a GitHub issue to:
#'
#' * Help you keep track of where you are in the process
#' * Feel a sense of satisfaction as you progress towards final submission
#' * Help watchers of your package stay informed.
#'
#' The checklist contains a generic set of steps that we've found to be helpful,
#' based on the type of release ("patch", "minor", or "major"). You're
#' encouraged to edit the issue to customize this list to meet your needs.
#' If you want to consistently add extra bullets for every release, you can
#' include your own custom bullets by providing a (unexported) a
#' `release_bullets()` function that returns a character vector.
#' (For historical reasons, `release_questions()` is also supported).
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
      ui_oops("Cancelling.")
      return(invisible())
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
      todo("Update (aspirational) install instructions in README"),
      todo("Proofread `Title:` and `Description:`"),
      todo("Check that all exported functions have `@return` and `@examples`"),
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

    todo("`urlchecker::url_check()`"),
    todo("`devtools::check(remote = TRUE, manual = TRUE)`"),
    todo("`devtools::check_win_devel()`"),
    todo("`rhub::check_for_cran()`"),
    todo("`rhub::check(platform = 'ubuntu-rchk')`", has_src),
    todo("`rhub::check_with_sanitizers()`", has_src),
    todo("`revdepcheck::revdep_check(num_workers = 4)`", on_cran),

    if (on_cran) todo("Update `cran-comments.md`"),
    todo("Review pkgdown reference index for, e.g., missing topics", has_pkgdown && type != "patch"),
    todo("Draft blog post", type != "patch"),
    release_extra(),
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
    todo("`usethis::use_dev_version()`"),
    todo("`usethis::use_news_md()`", !has_news),
    todo("Finish blog post", type != "patch"),
    todo("Tweet", type != "patch"),
    todo("Add link to blog post in pkgdown news menu", type != "patch")
  )
}

release_extra <- function(env = parent.env(globalenv())) {
  if (env_has(env, "release_bullets")) {
    paste0("* [ ] ", env$release_bullets())
  } else if (env_has(env, "release_questions")) {
    # For backwards compatibility with devtools
    paste0("* [ ] ", env$release_questions())
  } else {
    character()
  }
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
#' @description
#' Creates a __draft__ GitHub release for the current package using the current
#' version and `NEWS.md`. If you are comfortable that it is correct, you will
#' need to publish the release from GitHub.
#'
#' When `CRAN-RELEASE` is present (as produced by `devtools::release()` or
#' `devtools::submit_cran`), the target commit is extracted from there and,
#' after the draft release is successfully created, `CRAN-RELEASE` is deleted.
#' Otherwise, the release tag is set to current `HEAD`.
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
  gh <- gh_tr(tr)

  package <- package_data()
  release_name <- glue("{package$Package} {package$Version}")
  tag_name <- glue("v{package$Version}")
  kv_line("Release name", release_name)
  kv_line("Tag name", tag_name)

  cran_release <- proj_path("CRAN-RELEASE")
  if (file_exists(cran_release)) {
    lines <- read_utf8(cran_release)
    str_extract <- function(marker, pattern) {
      re_match(grep(marker, lines, value = TRUE), pattern)$.match
    }
    date <- str_extract("submitted.*on", "[0-9]{4}-[0-9]{2}-[0-9]{2}")
    ui_done("{ui_path('CRAN-RELEASE')} file found, from a submission on {date}")
    sha7 <- str_extract("commit", "[[:xdigit:]]{7}")
    kv_line("SHA", sha7)
    # the release endpoint requires the full sha
    sha <- gh("/repos/{owner}/{repo}/commits/{commit_sha}", commit_sha = sha7)$sha
  } else {
    ui_done("Tagging current HEAD commit for the release")
    challenge_non_default_branch()
    check_branch_pushed()
    sha <- gert::git_info(repo = git_repo())$commit
  }

  path <- proj_path("NEWS.md")
  if (file_exists(path)) {
    news <- news_latest(read_utf8(path))
  } else {
    news <- "Initial release"
  }

  release <- gh(
    "POST /repos/{owner}/{repo}/releases",
    name = release_name, tag_name = tag_name,
    target_commitish = sha, body = news, draft = TRUE
  )

  if (file_exists(cran_release)) {
    ui_done("{ui_path('CRAN-RELEASE')} deleted")
    file_delete(cran_release)
  }

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
