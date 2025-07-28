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
#'
#' ## Customization
#'
#' * If you want to consistently add extra bullets for every release, you can
#'   include your own custom bullets by providing an (unexported)
#'   `release_bullets()` function that returns a character vector.
#'   (For historical reasons, `release_questions()` is also supported).
#'
#' * If you want to check additional packages in the revdep check process,
#'   provide an (unexported) `release_extra_revdeps()` function that
#'   returns a character vector. This is currently only supported for
#'   Posit internal check tooling.
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
    ui_bullets(c(
      "!" = "It is very unusual to open a release issue on a repo you can't push
             to ({.val {tr$repo_spec}})."
    ))
    if (ui_nah("Do you really want to do this?")) {
      ui_bullets(c("x" = "Cancelling."))
      return(invisible())
    }
  }

  version <- version %||%
    choose_version(
      "What should the release version be?",
      which = c("major", "minor", "patch")
    )
  if (is.null(version)) {
    return(invisible(FALSE))
  }

  on_cran <- !is.null(cran_version())
  checklist <- release_checklist(version, on_cran, tr)

  gh <- gh_tr(tr)
  issue <- gh(
    "POST /repos/{owner}/{repo}/issues",
    title = glue("Release {project_name()} {version}"),
    body = paste0(checklist, "\n", collapse = "")
  )

  Sys.sleep(1)
  view_url(issue$html_url)
}

release_checklist <- function(version, on_cran, target_repo = NULL) {
  type <- release_type(version)
  cran_results <- cran_results_url()
  has_news <- file_exists(proj_path("NEWS.md"))
  has_pkgdown <- uses_pkgdown()
  has_lifecycle <- proj_desc()$has_dep("lifecycle")
  has_readme <- file_exists(proj_path("README.Rmd"))
  has_github_links <- has_github_links(target_repo)
  is_posit_pkg <- is_posit_pkg()
  milestone_num <- gh_milestone_number(target_repo, version)

  c(
    if (!on_cran) {
      c(
        "First release:",
        "",
        todo("`usethis::use_news_md()`", !has_news),
        todo("`usethis::use_cran_comments()`"),
        todo("Update (aspirational) install instructions in README"),
        todo("Proofread `Title:` and `Description:`"),
        todo(
          "Check that all exported functions have `@return` and `@examples`"
        ),
        todo(
          "Check that `Authors@R:` includes a copyright holder (role 'cph')"
        ),
        todo(
          "Check [licensing of included files](https://r-pkgs.org/license.html#sec-code-you-bundle)"
        ),
        todo("Review <https://github.com/DavisVaughan/extrachecks>"),
        ""
      )
    },
    "Prepare for release:",
    "",
    todo("`git pull`"),
    todo(
      "[Close v{version} milestone](../milestone/{milestone_num})",
      !is.na(milestone_num)
    ),
    todo("Check [current CRAN check results]({cran_results})", on_cran),
    todo(
      "
      Check if any deprecation processes should be advanced, as described in \\
      [Gradual deprecation](https://lifecycle.r-lib.org/articles/communicate.html#gradual-deprecation)",
      type != "patch" && has_lifecycle
    ),
    todo("`usethis::use_news_md()`", on_cran && !has_news),
    todo(
      "[Polish NEWS](https://style.tidyverse.org/news.html#news-release)",
      on_cran
    ),
    todo("`usethis::use_github_links()`", !has_github_links),
    todo("`urlchecker::url_check()`"),
    todo("`devtools::build_readme()`", has_readme),
    todo("`devtools::check(remote = TRUE, manual = TRUE)`"),
    todo("`devtools::check_win_devel()`"),
    release_revdepcheck(on_cran, is_posit_pkg),
    todo("Update `cran-comments.md`", on_cran),
    todo("`git push`"),
    todo("Draft blog post", type != "patch"),
    release_extra_bullets(),
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
    todo("Finish & publish blog post", type != "patch"),
    todo("Add link to blog post in pkgdown news menu", type != "patch"),
    todo("`usethis::use_github_release()`"),
    todo("`usethis::use_dev_version(push = TRUE)`"),
    todo("`usethis::use_news_md()`", !has_news),
    todo("Share on social media", type != "patch"),
    todo(
      "Slack link to blog post, bluesky, and linkedin in #open-source-comms",
      type != "patch" && is_posit_pkg
    )
  )
}

gh_milestone_number <- function(target_repo, version, state = "open") {
  gh <- gh_tr(target_repo)
  milestones <- tryCatch(
    gh("/repos/{owner}/{repo}/milestones", state = state),
    error = function(e) list()
  )
  titles <- map_chr(milestones, "title")
  numbers <- map_int(milestones, "number")

  numbers[match(paste0("v", version), titles)]
}

# Get revdeps for current package
get_revdeps <- function() {
  pkg <- proj_desc()$get_field("Package")
  tools::package_dependencies(pkg, which = "all", reverse = TRUE)[[pkg]]
}

release_revdepcheck <- function(
  on_cran = TRUE,
  is_posit_pkg = TRUE,
  env = NULL
) {
  if (!on_cran || length(get_revdeps()) == 0) {
    return()
  }

  env <- env %||% safe_pkg_env()
  if (env_has(env, "release_extra_revdeps")) {
    extra <- env$release_extra_revdeps()
    stopifnot(is.character(extra))
  } else {
    extra <- character()
  }

  if (is_posit_pkg) {
    if (length(extra) > 0) {
      extra_code <- paste0(deparse(extra), collapse = "")
      todo("`revdepcheck::cloud_check(extra_revdeps = {extra_code})`")
    } else {
      todo("`revdepcheck::cloud_check()`")
    }
  } else {
    todo("`revdepcheck::revdep_check(num_workers = 4)`")
  }
}

release_extra_bullets <- function(env = NULL) {
  env <- env %||% safe_pkg_env()

  if (env_has(env, "release_bullets")) {
    paste0("* [ ] ", env$release_bullets())
  } else if (env_has(env, "release_questions")) {
    # For backwards compatibility with devtools
    paste0("* [ ] ", env$release_questions())
  } else {
    character()
  }
}

safe_pkg_env <- function() {
  tryCatch(
    ns_env(project_name()),
    error = function(e) emptyenv()
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

#' Publish a GitHub release
#'
#' @description
#' Pushes the current branch (if safe) then publishes a GitHub release for the
#' latest CRAN submission.
#'
#' If you use [devtools::submit_cran()] to submit to CRAN, information about the
#' submitted state is captured in a `CRAN-SUBMISSION` file.
#' `use_github_release()` uses this info to populate the GitHub release notes
#' and, after success, deletes the file. In the absence of such a file, we
#' assume that current state (SHA of `HEAD`, package version, NEWS) is the
#' submitted state.
#'
#' @param publish If `TRUE`, publishes a release. If `FALSE`, creates a draft
#'   release.
#' @export
use_github_release <- function(publish = TRUE) {
  check_is_package("use_github_release()")

  tr <- target_repo(github_get = TRUE, ok_configs = c("ours", "fork"))
  check_can_push(tr = tr, "to create a release")

  dat <- get_release_data(tr)
  release_name <- glue("{dat$Package} {dat$Version}")
  tag_name <- glue("v{dat$Version}")
  kv_line("Release name", release_name)
  kv_line("Tag name", tag_name)
  kv_line("SHA", dat$SHA)

  if (git_can_push()) {
    git_push()
  }
  check_github_has_SHA(SHA = dat$SHA, tr = tr)

  on_cran <- !is.null(cran_version())
  news <- get_release_news(SHA = dat$SHA, tr = tr, on_cran = on_cran)

  gh <- gh_tr(tr)

  ui_bullets("Publishing {tag_name} release to GitHub")
  release <- gh(
    "POST /repos/{owner}/{repo}/releases",
    name = release_name,
    tag_name = tag_name,
    target_commitish = dat$SHA,
    body = news,
    draft = !publish
  )
  ui_bullets("Release at {.url {release$html_url}}")

  if (!is.null(dat$file)) {
    ui_bullets("Deleting {.path {dat$file}}")
    file_delete(dat$file)
  }

  invisible()
}

get_release_data <- function(tr = target_repo(github_get = TRUE)) {
  cran_submission <-
    path_first_existing(proj_path(c("CRAN-SUBMISSION", "CRAN-RELEASE")))

  if (is.null(cran_submission)) {
    ui_bullets(c("v" = "Using current HEAD commit for the release."))
    challenge_non_default_branch()
    check_branch_pushed()
    return(list(
      Package = project_name(),
      Version = proj_version(),
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
      version <- proj_version()
    } else {
      tf <- withr::local_tempfile()
      gh(
        "/repos/{owner}/{repo}/contents/{path}",
        path = "DESCRIPTION",
        ref = sha,
        .destfile = tf,
        .accept = "application/vnd.github.v3.raw"
      )
      version <- desc::desc_get_version(tf)
    }

    out <- list(
      Version = version,
      Date = Sys.Date(),
      SHA = sha
    )
  }

  out$Package <- project_name()
  out$file <- cran_submission
  ui_bullets(c(
    "{.path {pth(out$file)}} file found, from a submission on {as.Date(out$Date)}."
  ))

  out
}

check_github_has_SHA <- function(
  SHA = gert::git_info(repo = git_repo())$commit,
  tr = target_repo(github_get = TRUE)
) {
  safe_gh <- purrr::safely(gh_tr(tr))
  SHA_GET <- safe_gh(
    "/repos/{owner}/{repo}/git/commits/{commit_sha}",
    commit_sha = SHA
  )
  if (is.null(SHA_GET$error)) {
    return()
  }
  if (inherits(SHA_GET$error, "http_error_404")) {
    ui_abort(c(
      "Can't find SHA {.val {substr(SHA, 1, 7)}} in {.val {tr$repo_spec}}.",
      "Do you need to push?"
    ))
  }
  ui_abort("Internal error: Unexpected error when checking for SHA on GitHub.")
}

get_release_news <- function(
  SHA = gert::git_info(repo = git_repo())$commit,
  tr = target_repo(github_get = TRUE),
  on_cran = !is.null(cran_version())
) {
  HEAD <- gert::git_info(repo = git_repo())$commit

  if (HEAD == SHA) {
    news_path <- proj_path("NEWS.md")
    news <- if (file_exists(news_path)) read_utf8(news_path) else NULL
  } else {
    news <- tryCatch(
      read_github_file(
        tr$repo_spec,
        path = "NEWS.md",
        ref = SHA,
        host = tr$api_url
      ),
      github_error = NULL
    )
  }

  if (is.null(news)) {
    ui_bullets(c(
      "x" = "Can't find {.path {pth('NEWS.md')}} in the released package source.",
      "i" = "{.pkg usethis} consults this file for release notes.",
      "i" = "Call {.run usethis::use_news_md()} to set this up for the future."
    ))
    if (on_cran) "-- no release notes --" else "Initial release"
  } else {
    news_latest(news)
  }
}

cran_version <- function(package = project_name(), available = NULL) {
  if (!curl::has_internet()) {
    return(NULL)
  }

  if (is.null(available)) {
    # Guard against CRAN mirror being unset
    available <- tryCatch(
      available.packages(repos = default_cran_mirror()),
      error = function(e) NULL
    )
    if (is.null(available)) {
      return(NULL)
    }
  }

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
    ui_abort("No top-level headings found in {.path {pth('NEWS.md')}}.")
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

is_posit_pkg <- function() {
  is_posit_cph_or_fnd() || is_in_posit_org()
}

is_posit_cph_or_fnd <- function() {
  if (!is_package()) {
    return(FALSE)
  }
  roles <- get_posit_roles()
  "cph" %in% roles || "fnd" %in% roles
}

is_posit_person_canonical <- function() {
  if (!is_package()) {
    return(FALSE)
  }
  roles <- get_posit_roles()
  length(roles) > 0 &&
    "fnd" %in% roles &&
    "cph" %in% roles &&
    attr(roles, "appears_in", exact = TRUE) == "given" &&
    attr(roles, "appears_as", exact = TRUE) == "Posit Software, PBC" &&
    attr(roles, "ror", exact = TRUE) %in% "03wc8by49"
}

get_posit_roles <- function() {
  if (!is_package()) {
    return()
  }

  desc <- proj_desc()
  fnd <- unclass(desc$get_author("fnd"))
  cph <- unclass(desc$get_author("cph"))

  detect_posit <- function(x) {
    any(grepl("rstudio|posit", tolower(x[c("given", "family")])))
  }
  fnd <- purrr::keep(fnd, detect_posit)
  cph <- purrr::keep(cph, detect_posit)

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

  comment <- person$comment %||% character()
  attr(out, "ror") <- comment["ROR"]

  out
}

is_in_posit_org <- function() {
  if (!is_package()) {
    return(FALSE)
  }
  desc <- proj_desc()
  urls <- desc$get_urls()
  dat <- parse_github_remotes(urls)
  dat <- dat[dat$host == "github.com", ]
  purrr::some(dat$repo_owner, \(x) x %in% posit_orgs())
}

posit_orgs <- function() {
  c(
    "tidyverse",
    "r-lib",
    "tidymodels",
    "rstudio",
    "posit-dev"
  )
}

todo <- function(x, cond = TRUE) {
  x <- glue(x, .envir = parent.frame())
  if (cond) {
    paste0("* [ ] ", x)
  }
}

author_has_rstudio_email <- function() {
  if (!is_package()) {
    return()
  }
  desc <- proj_desc()
  any(grepl("@rstudio[.]com", tolower(desc$get_authors())))
}

pkg_minimum_r_version <- function() {
  deps <- proj_desc()$get_deps()
  r_dep <- deps[deps$package == "R" & deps$type == "Depends", "version"]
  if (length(r_dep) > 0) {
    numeric_version(gsub("[^0-9.]", "", r_dep))
  } else {
    NA_character_
  }
}

# Borrowed from pak, but modified also retain user's non-cran repos:
# https://github.com/r-lib/pak/blob/168ab5d58fc244e5084c2800c87b8a574d66c3ba/R/default-cran-mirror.R
default_cran_mirror <- function() {
  repos <- getOption("repos")
  cran <- repos["CRAN"]
  if (is.null(cran) || is.na(cran) || cran == "@CRAN@") {
    repos["CRAN"] <- "https://cloud.r-project.org"
  }
  repos
}
