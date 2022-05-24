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

  Sys.sleep(1)
  view_url(issue$html_url)
}

release_checklist <- function(version, on_cran) {
  type <- release_type(version)
  cran_results <- cran_results_url()
  has_src <- dir_exists(proj_path("src"))
  has_news <- file_exists(proj_path("NEWS.md"))
  has_pkgdown <- uses_pkgdown()
  has_readme <- file_exists(proj_path("README.Rmd"))
  is_rstudio_pkg <- is_rstudio_pkg()

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
    todo("`git pull`"),
    todo("Check [current CRAN check results]({cran_results})", on_cran),
    todo("[Polish NEWS](https://style.tidyverse.org/news.html#news-release)", on_cran),
    todo("`devtools::build_readme()`", has_readme),
    todo("`urlchecker::url_check()`"),
    todo("`devtools::check(remote = TRUE, manual = TRUE)`"),
    todo("`devtools::check_win_devel()`"),
    todo("`rhub::check_for_cran()`"),
    todo("`rhub::check(platform = 'ubuntu-rchk')`", has_src),
    todo("`rhub::check_with_sanitizers()`", has_src),
    todo("`revdepcheck::revdep_check(num_workers = 4)`", on_cran && !is_rstudio_pkg),
    todo("`revdepcheck::cloud_check()`", on_cran && is_rstudio_pkg),
    todo("Update `cran-comments.md`", on_cran),
    todo("`git push`"),
    todo("Draft blog post", type != "patch"),
    todo("Slack link to draft blog in #open-source-comms", type != "patch" && is_rstudio_pkg),
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
    todo("`git push`"),
    todo("`usethis::use_github_release()`"),
    todo("`usethis::use_dev_version()`"),
    todo("`usethis::use_news_md()`", !has_news),
    todo("`git push`"),
    todo("Finish blog post", type != "patch"),
    todo("Tweet", type != "patch"),
    todo("Add link to blog post in pkgdown news menu", type != "patch")
  )
}

release_extra <- function(env = NULL) {
  if (is.null(env)) {
    env <- tryCatch(
      pkg_env(project_name()),
      error = function(e) emptyenv()
    )
  }

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
#' Creates a __draft__ GitHub release for the current package. Once you are
#' satisfied that it is correct, you will need to publish the release from
#' GitHub. The key pieces of info are which commit / SHA to tag, the associated
#' package version, and the relevant NEWS entries.
#'
#' If you use `devtools::release()` or `devtools::submit_cran()` to submit to
#' CRAN, information about the submitted state is captured in a CRAN-SUBMISSION
#' or CRAN-RELEASE file. `use_github_release()` uses this info to populate the
#' draft GitHub release and, after success, deletes the CRAN-SUBMISSION or
#' CRAN-RELEASE file.
#'
#' In the absence of such a file, we must fall back to assuming the current
#' state (SHA of `HEAD`, package version, NEWS) is the submitted state.
#'
#' @param host,auth_token `r lifecycle::badge("deprecated")`: No longer
#'   consulted now that usethis allows the gh package to lookup a token based on
#'   a URL determined from the current project's GitHub remotes.
#' @export
use_github_release <- function(host = deprecated(),
                               auth_token = deprecated()) {
  check_is_package("use_github_release()")
  if (lifecycle::is_present(host)) {
    deprecate_warn_host("use_github_release")
  }
  if (lifecycle::is_present(auth_token)) {
    deprecate_warn_auth_token("use_github_release")
  }

  tr <- target_repo(github_get = TRUE, ok_configs = c("ours", "fork"))
  check_can_push(tr = tr, "to draft a release")

  dat <- get_release_data(tr)
  release_name <- glue("{dat$Package} {dat$Version}")
  tag_name <- glue("v{dat$Version}")
  kv_line("Release name", release_name)
  kv_line("Tag name", tag_name)
  kv_line("SHA", dat$SHA)

  check_github_has_SHA(SHA = dat$SHA, tr = tr)

  news <- get_release_news(SHA = dat$SHA, tr = tr)

  gh <- gh_tr(tr)
  release <- gh(
    "POST /repos/{owner}/{repo}/releases",
    name = release_name, tag_name = tag_name,
    target_commitish = dat$SHA, body = news, draft = TRUE
  )

  if (!is.null(dat$file)) {
    ui_done("{ui_path(dat$file)} deleted")
    file_delete(dat$file)
  }

  Sys.sleep(1)
  view_url(release$html_url)
  ui_todo("Publish the release via \"Edit draft\" > \"Publish release\"")
}

get_release_data <- function(tr = target_repo(github_get = TRUE)) {
  package <- package_data()
  cran_submission <-
    path_first_existing(proj_path(c("CRAN-SUBMISSION", "CRAN-RELEASE")))

  if (is.null(cran_submission)) {
    ui_done("Using current HEAD commit for the release")
    challenge_non_default_branch()
    check_branch_pushed()
    return(list(
      Package = package$Package,
      Version = package$Version,
      SHA = gert::git_info(repo = git_repo())$commit
    ))
  }

  if (path_file(cran_submission) == "CRAN-SUBMISSION") {
    # new style ----
    # Version: 2.4.2
    # Date: 2021-10-13 20:40:36 UTC
    # SHA: fbe18b5a22be8ebbb61fa7436e826ba8d7f485a9
    out <- as.list(read.dcf(cran_submission)[1, ])
  }

  if (path_file(cran_submission) == "CRAN-RELEASE") {
    gh <- gh_tr(tr)
    # old style ----
    # This package was submitted to CRAN on 2021-10-13.
    # Once it is accepted, delete this file and tag the release (commit e10658f5).
    lines <- read_utf8(cran_submission)
    str_extract <- function(marker, pattern) {
      re_match(grep(marker, lines, value = TRUE), pattern)$.match
    }
    date <- str_extract("submitted.*on", "[0-9]{4}-[0-9]{2}-[0-9]{2}")
    sha <- str_extract("commit", "[[:xdigit:]]{7,40}")
    if (nchar(sha) != 40) {
      # the release endpoint requires the full sha
      sha <-
        gh("/repos/{owner}/{repo}/commits/{commit_sha}", commit_sha = sha)$sha
    }

    HEAD <- gert::git_info(repo = git_repo())$commit
    if (HEAD == sha) {
      version <- package$Version
    } else {
      tf <- glue("{package_data()$Package}-DESCRIPTION-{substr(sha, 1, 7)}-")
      tf <- withr::local_tempfile(pattern = tf)
      gh(
        "/repos/{owner}/{repo}/contents/{path}",
        path = "DESCRIPTION", ref = sha,
        .destfile = tf,
        .accept = "application/vnd.github.v3.raw"
      )
      version <- desc::desc(file = tf)$get_version()
    }

    out <- list(
      Version = version,
      Date = Sys.Date(),
      SHA = sha
    )
  }

  out$Package <- package$Package
  out$file <- cran_submission
  ui_done("
    {ui_path(out$file)} file found, from a submission on {as.Date(out$Date)}")

  out
}

check_github_has_SHA <- function(SHA = gert::git_info(repo = git_repo())$commit,
                                 tr = target_repo(github_get = TRUE)) {
  safe_gh <- purrr::safely(gh_tr(tr))
  SHA_GET <- safe_gh(
    "/repos/{owner}/{repo}/git/commits/{commit_sha}",
    commit_sha = SHA
  )
  if (is.null(SHA_GET$error)) {
    return()
  }
  if (inherits(SHA_GET$error, "http_error_404")) {
    ui_stop("
      Can't find SHA {ui_value(substr(SHA, 1, 7))} in {ui_value(tr$repo_spec)}.
      Do you need to push?")
  }
  ui_stop("Internal error: Unexpected error when checking for SHA on GitHub")
}

get_release_news <- function(SHA = gert::git_info(repo = git_repo())$commit,
                             tr = target_repo(github_get = TRUE)) {
  package <- package_data()
  HEAD <- gert::git_info(repo = git_repo())$commit

  if (HEAD == SHA) {
    news_path <- proj_path("NEWS.md")
  } else {
    news_path <- glue("{package_data()$Package}-NEWS-{substr(SHA, 1, 7)}-")
    news_path <- withr::local_tempfile(pattern = news_path)
    gh <- purrr::possibly(gh_tr(tr), otherwise = NULL)
    gh(
      "/repos/{owner}/{repo}/contents/{path}",
      path = "NEWS.md", ref = SHA,
      .destfile = news_path,
      .accept = "application/vnd.github.v3.raw"
    )
  }

  if (file_exists(news_path)) {
    news <- news_latest(read_utf8(news_path))
  } else {
    news <- "Initial release"
  }

  news
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

is_rstudio_pkg <- function() {
  is_rstudio_cph_or_fnd() || is_in_rstudio_org()
}

is_rstudio_cph_or_fnd <- function() {
  if (!is_package()) {
    return(FALSE)
  }
  roles <- get_rstudio_roles()
  "cph" %in% roles || "fnd" %in% roles
}

is_rstudio_person_canonical <- function() {
  if (!is_package()) {
    return(FALSE)
  }
  roles <- get_rstudio_roles()
  length(roles) > 0 &&
    "fnd" %in% roles &&
    "cph" %in% roles &&
    attr(roles, "appears_in", exact = TRUE) == "given" &&
    attr(roles, "appears_as", exact = TRUE) == "RStudio"
}

get_rstudio_roles <- function() {
  if (!is_package()) {
    return()
  }

  desc <- desc::desc(file = proj_get())
  fnd <- unclass(desc$get_author("fnd"))
  cph <- unclass(desc$get_author("cph"))

  detect_rstudio <- function(x) {
    any(grepl("rstudio", tolower(x[c("given", "family")])))
  }
  fnd <- purrr::keep(fnd, detect_rstudio)
  cph <- purrr::keep(cph, detect_rstudio)

  if (length(fnd) < 1 && length(cph) < 1) {
    return(character())
  }

  person <- c(fnd, cph)[[1]]
  out <- person$role
  if (!is.null(person$given) && nzchar(person$given)) {
    attr(out, "appears_as") <- person$given
    attr(out, "appears_in") <- "given"
  } else {
    attr(out, "appears_as") <- person$family
    attr(out, "appears_in") <- "family"
  }
  out
}

is_in_rstudio_org <- function() {
  if (!is_package()) {
    return(FALSE)
  }
  desc <- desc::desc(file = proj_get())
  urls <- desc$get_urls()
  dat <- parse_github_remotes(urls)
  dat <- dat[dat$host == "github.com", ]
  purrr::some(dat$repo_owner, ~ .x %in% rstudio_orgs())
}

rstudio_orgs <- function() {
  c(
    "tidyverse",
    "r-lib",
    "tidymodels",
    "rstudio"
  )
}

todo <- function(x, cond = TRUE) {
  x <- glue(x, .envir = parent.frame())
  if (cond) {
    paste0("* [ ] ", x)
  }
}
