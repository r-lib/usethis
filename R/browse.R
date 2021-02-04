#' Visit important project-related web pages
#'
#' These functions take you to various web pages associated with a project
#' (often, an R package) and return the target URL(s) invisibly. To form
#' these URLs we consult:
#' * Git remotes configured for the active project that appear to be hosted on
#'   a GitHub deployment
#' * DESCRIPTION file for the active project or the specified `package`. The
#'   DESCRIPTION file is sought first in the local package library and then
#'   on CRAN.
#' * Fixed templates:
#'   - Travis CI: `https://travis-ci.{EXT}/{OWNER}/{PACKAGE}`
#'   - Circle CI: `https://circleci.com/gh/{OWNER}/{PACKAGE}`
#'   - CRAN landing page: `https://cran.r-project.org/package={PACKAGE}`
#'   - GitHub mirror of a CRAN package: `https://github.com/cran/{PACKAGE}`
#'   Templated URLs aren't checked for existence, so there is no guarantee
#'   there will be content at the destination.
#'
#' @details
#' * `browse_package()`: Assembles a list of URLs and lets user choose one to
#'   visit in a web browser. In a non-interactive session, returns all
#'   discovered URLs.
#' * `browse_project()`: Thin wrapper around `browse_package()` that always
#'   targets the active usethis project.
#' * `browse_github()`: Visits a GitHub repository associated with the project.
#'   In the case of a fork, you might be asked to specify if you're interested
#'   in the source repo or your fork.
#' * `browse_github_issues()`: Visits the GitHub Issues index or one specific
#'   issue.
#' * `browse_github_pulls()`: Visits the GitHub Pull Request index or one
#'   specific pull request.
#' * `browse_travis()`: Visits the project's page on
#'   [Travis CI](https://travis-ci.com).
#' * `browse_circleci()`: Visits the project's page on
#'   [Circle CI](https://circleci.com).
#' * `browse_cran()`: Visits the package on CRAN, via the canonical URL.
#'
#' @param package Name of package. If `NULL`, the active project is targeted,
#'   regardless of whether it's an R package or not.
#' @param number Optional, to specify an individual GitHub issue or pull
#'   request. Can be a number or `"new"`.
#'
#' @examples
#' # works on the active project
#' # browse_project()
#'
#' browse_package("httr")
#' browse_github("gh")
#' browse_github_issues("fs")
#' browse_github_issues("fs", 1)
#' browse_github_pulls("curl")
#' browse_github_pulls("curl", 183)
#' browse_travis("gert", ext = "org")
#' browse_cran("MASS")
#' @name browse-this
NULL

#' @export
#' @rdname browse-this
browse_package <- function(package = NULL) {
  stopifnot(is.null(package) || is_string(package))
  if (is.null(package)) {
    check_is_project()
  }

  urls <- character()
  details <- list()

  if (is.null(package) && uses_git()) {
    grl <- github_remote_list(these = NULL)
    ord <- c(
      which(grl$remote == "origin"),
      which(grl$remote == "upstream"),
      which(!grl$remote %in% c("origin", "upstream"))
    )
    grl <- grl[ord, ]
    grl <- set_names(grl$url, nm = grl$remote)
    parsed <- parse_github_remotes(grl)
    urls <- c(urls, glue_data(parsed, "https://{host}/{repo_owner}/{repo_name}"))
    details <- c(details, map(parsed$name, ~ glue("{ui_value(.x)} remote")))
  }

  desc_urls_dat <- desc_urls(package, include_cran = TRUE)
  urls <- c(urls, desc_urls_dat$url)
  details <- c(
    details,
    map(
      desc_urls_dat$desc_field,
      ~ if (is.na(.x)) "CRAN" else glue("{ui_field(.x)} field in DESCRIPTION")
    )
  )
  if (length(urls) == 0) {
    ui_oops("Can't find any URLs")
    return(invisible(character()))
  }

  if (!is_interactive()) {
    return(invisible(urls))
  }

  prompt <- "Which URL do you want to visit? (0 to exit)"
  pretty <- purrr::map2(
    format(urls, justify = "left"), details,
    ~ glue("{.x} ({.y})")
  )
  choice <- utils::menu(title = prompt, choices = pretty)
  if (choice == 0) {
    return(invisible(character()))
  }
  view_url(urls[choice])
}

#' @export
#' @rdname browse-this
browse_project <- function() browse_package(NULL)

#' @export
#' @rdname browse-this
browse_github <- function(package = NULL) {
  view_url(github_url(package))
}

#' @export
#' @rdname browse-this
browse_github_issues <- function(package = NULL, number = NULL) {
  view_url(github_url(package), "issues", number)
}

#' @export
#' @rdname browse-this
browse_github_pulls <- function(package = NULL, number = NULL) {
  pull <- if (is.null(number)) "pulls" else "pull"
  view_url(github_url(package), pull, number)
}
#' @export
#' @rdname browse-this
browse_github_actions <- function(package = NULL) {
  view_url(github_url(package), "actions")
}

#' @export
#' @rdname browse-this
#' @param ext Version of travis to use.
browse_travis <- function(package = NULL, ext = c("com", "org")) {
  gh <- github_url(package)
  ext <- arg_match(ext)
  travis_url <- glue("travis-ci.{ext}")
  view_url(sub("github.com", travis_url, gh))
}

#' @export
#' @rdname browse-this
browse_circleci <- function(package = NULL) {
  gh <- github_url(package)
  circle_url <- "circleci.com/gh"
  view_url(sub("github.com", circle_url, gh))
}

#' @export
#' @rdname browse-this
browse_cran <- function(package = NULL) {
  view_url(cran_home(package))
}

# Try to get a GitHub repo spec from these places:
# 1. Remotes associated with GitHub (active project)
# 2. BugReports/URL fields of DESCRIPTION (active project or arbitrary
#    installed package)
github_url <- function(package = NULL) {
  stopifnot(is.null(package) || is_string(package))

  if (is.null(package)) {
    check_is_project()
    url <- github_url_from_git_remotes()
    if (!is.null(url)) {
      return(url)
    }
  }

  desc_urls_dat <- desc_urls(package)

  if (is.null(desc_urls_dat)) {
    if (is.null(package)) {
      ui_stop("
        Project {ui_value(project_name())} has no DESCRIPTION file and \\
        has no GitHub remotes configured
        No way to discover URLs")
    } else {
      ui_stop("
        Can't find DESCRIPTION for package {ui_value(package)} locally \\
        or on CRAN
        No way to discover URLs")
    }
  }

  desc_urls_dat <- desc_urls_dat[desc_urls_dat$is_github, ]

  if (nrow(desc_urls_dat) > 0) {
    parsed <- parse_github_remotes(desc_urls_dat$url[[1]])
    return(glue_data_chr(parsed, "https://{host}/{repo_owner}/{repo_name}"))
  }

  if (is.null(package)) {
    ui_stop("
      Project {ui_value(project_name())} has no GitHub remotes configured \\
      and has no GitHub URLs in DESCRIPTION")
  }
  ui_warn("
    Package {ui_value(package)} has no GitHub URLs in DESCRIPTION
    Trying the GitHub CRAN mirror")
  glue_chr("https://github.com/cran/{package}")
}

cran_home <- function(package = NULL) {
  package <- package %||% project_name()
  glue_chr("https://cran.r-project.org/package={package}")
}

# returns NULL, if no DESCRIPTION found
# returns 0-row data frame, if DESCRIPTION holds no URLs
# returns data frame, if successful
# include_cran whether to include CRAN landing page, if we consult it
desc_urls <- function(package = NULL, include_cran = FALSE, desc = NULL) {
  maybe_desc <- purrr::possibly(desc::desc, otherwise = NULL)
  desc_from_cran <- FALSE

  if (is.null(desc)) {
    if (is.null(package)) {
      desc <- maybe_desc(file = proj_get())
      if (is.null(desc)) {
        return()
      }
    } else {
      desc <- maybe_desc(package = package)
      if (is.null(desc)) {
        cran_desc_url <-
          glue("https://cran.rstudio.com/web/packages/{package}/DESCRIPTION")
        suppressWarnings(
          desc <- maybe_desc(text = readLines(cran_desc_url))
        )
        if (is.null(desc)) {
          return()
        }
        desc_from_cran <- TRUE
      }
    }
  }

  url <- desc$get_urls()
  bug_reports <- desc$get_field("BugReports", default = character())
  cran <-
    if (include_cran && desc_from_cran) cran_home(package) else character()
  dat <- data.frame(
    desc_field = c(
      rep_len("URL", length.out = length(url)),
      rep_len("BugReports", length.out = length(bug_reports)),
      rep_len(NA, length.out = length(cran))
    ),
    url = c(url, bug_reports, cran),
    stringsAsFactors = FALSE
  )
  dat <- cbind(dat, re_match(dat$url, github_remote_regex))
  # TODO: could have a more sophisticated understanding of GitHub deployments
  dat$is_github <- !is.na(dat$.match) & grepl("github", dat$host)
  dat[c("url", "desc_field", "is_github")]
}
