#' Create an upkeep checklist in a GitHub issue
#'
#' @description
#' This opens an issue in your package repository with a checklist of tasks for
#' regular maintenance of your package. This is a fairly opinionated list of
#' tasks but we believe taking care of them will generally make your package
#' better, easier to maintain, and more enjoyable for your users. Some of the
#' tasks are meant to be performed only once (and once completed shouldn't show
#' up in subsequent lists), and some should be reviewed periodically. The
#' tidyverse team uses a similar function [use_tidy_upkeep_issue()] for our
#' annual package Spring Cleaning.
#'
#' @param year Year you are performing the upkeep, used in the issue title.
#'   Defaults to current year
#'
#' @export
#' @examples
#' \dontrun{
#' use_upkeep_issue(2023)
#' }
use_upkeep_issue <- function(year = NULL) {
  make_upkeep_issue(year = year, tidy = FALSE)
}

make_upkeep_issue <- function(year, tidy) {
  who <- if (tidy) "use_tidy_upkeep_issue()" else "use_upkeep_issue()"
  check_is_package(who)

  tr <- target_repo(github_get = TRUE)

  if (!isTRUE(tr$can_push)) {
    ui_bullets(c(
      "!" = "It is very unusual to open an upkeep issue on a repo you can't push
             to ({.val {tr$repo_spec}})."
    ))
    if (ui_nah("Do you really want to do this?")) {
      ui_bullets(c("x" = "Cancelling."))
      return(invisible())
    }
  }

  gh <- gh_tr(tr)
  if (tidy) {
    checklist <- tidy_upkeep_checklist(year, repo_spec = tr$repo_spec)
  } else {
    checklist <- upkeep_checklist(tr)
  }

  title_year <- year %||% format(Sys.Date(), "%Y")

  issue <- gh(
    "POST /repos/{owner}/{repo}/issues",
    title = glue("Upkeep for {project_name()} ({title_year})"),
    body = paste0(checklist, "\n", collapse = ""),
    labels = if (tidy) list("upkeep")
  )
  Sys.sleep(1)
  view_url(issue$html_url)
}

upkeep_checklist <- function(target_repo = NULL) {
  has_github_links <- has_github_links(target_repo)

  bullets <- c(
    todo("`usethis::use_readme_rmd()`", !file_exists(proj_path("README.Rmd"))),
    todo("`usethis::use_roxygen_md()`", !is_true(uses_roxygen_md())),
    todo("`usethis::use_github_links()`", !has_github_links),
    todo("`usethis::use_pkgdown_github_pages()`", !uses_pkgdown()),
    todo("`usethis::use_tidy_description()`"),
    todo(
      "
      `usethis::use_package_doc()`
      Consider letting usethis manage your `@importFrom` directives here. \\
      `usethis::use_import_from()` is handy for this.",
      !has_package_doc()
    ),
    todo(
      "
      `usethis::use_testthat()`. \\
      Learn more about testing at <https://r-pkgs.org/tests.html>",
      !uses_testthat()
    ),
    todo(
      "
      `usethis::use_testthat(3)` and upgrade to 3e, \\
      [testthat 3e vignette](https://testthat.r-lib.org/articles/third-edition.html)",
      uses_old_testthat_edition(current = 3)
    ),
    todo("
      Align the names of `R/` files and `test/` files for workflow happiness. \\
      The docs for `usethis::use_r()` include a helpful script. \\
      `usethis::rename_files()` may be be useful."),
    todo(
      "Consider changing default branch from `master` to `main`",
      git_default_branch() == "master"
    ),
    todo("`usethis::use_code_of_conduct()`", !has_coc()),
    todo(
      "Remove description of test environments from `cran-comments.md`.
      See `usethis::use_cran_comments()`.",
      has_old_cran_comments()
    ),
    todo("
      Add alt-text to pictures, plots, etc; see \\
      <https://posit.co/blog/knitr-fig-alt/> for examples"),
      "",
      "Set up or update GitHub Actions. \\
      Updating workflows to the latest version will often fix troublesome actions:",
      todo("`usethis::use_github_action('check-standard')`"),
      todo("`usethis::use_github_action('pkgdown')`", uses_pkgdown()),
      todo("`usethis::use_github_action('test-coverage')`", uses_testthat())
  )

  c(bullets, upkeep_extra_bullets(), checklist_footer(tidy = FALSE))
}

# tidyverse upkeep issue -------------------------------------------------------

#' @export
#' @rdname tidyverse
#' @param year Approximate year when you last touched this package. If `NULL`,
#'   the default, will give you a full set of actions to perform.
use_tidy_upkeep_issue <- function(year = NULL) {
  make_upkeep_issue(year = year, tidy = TRUE)
}

# for mocking
Sys.Date <- NULL

tidy_upkeep_checklist <- function(year = NULL, repo_spec = "OWNER/REPO") {

  posit_pkg <- is_posit_pkg()
  posit_person_ok <- is_posit_person_canonical()

  year <- year %||% 2000

  bullets <- c(
    "### To begin",
    "",
    todo('`pr_init("upkeep-{format(Sys.Date(), "%Y-%m")}")`'),
    ""
  )

  if (year <= 2000) {
    bullets <- c(
      bullets,
      "### Pre-history",
      "",
      todo("`usethis::use_readme_rmd()`"),
      todo("`usethis::use_roxygen_md()`"),
      todo("`usethis::use_github_links()`"),
      todo("`usethis::use_pkgdown_github_pages()`"),
      todo("`usethis::use_tidy_github_labels()`"),
      todo("`usethis::use_tidy_style()`"),
      todo("`urlchecker::url_check()`"),
      ""
    )
  }
  if (year <= 2020) {
    bullets <- c(
      bullets,
      "### 2020",
      "",
      todo("`usethis::use_package_doc()`"),
      todo("`usethis::use_testthat(3)`"),
      todo("Align the names of `R/` files and `test/` files"),
      ""
    )
  }
  if (year <= 2021) {
    bullets <- c(
      bullets,
      "### 2021",
      "",
      todo("Remove check environments section from `cran-comments.md`"),
      todo("Use lifecycle instead of artisanal deprecation messages"),
      ""
    )
  }
  if (year <= 2022) {
    bullets <- c(
      bullets,
      "### 2022",
      "",
      todo("Handle and close any still-open `master` --> `main` issues"),
      todo('`usethis:::use_codecov_badge("{repo_spec}")`'),
      todo("Update pkgdown site using instructions at <https://tidytemplate.tidyverse.org>"),
      todo("Update lifecycle badges with more accessible SVGs: `usethis::use_lifecycle()`"),
      ""
    )
  }

  if (year <= 2023) {
    desc <- proj_desc()

    bullets <- c(
      bullets,
      "### 2023",
      "",
      todo(
        "
        Update email addresses *@rstudio.com -> *@posit.co",
        author_has_rstudio_email()
      ),
      todo(
        '
        Update copyright holder in DESCRIPTION: \\
        `person("Posit Software, PBC", role = c("cph", "fnd"))`',
        posit_pkg && !posit_person_ok
      ),
      todo(
        "
        Run `devtools::document()` to re-generate package-level help topic \\
        with DESCRIPTION changes",
        author_has_rstudio_email() || (posit_pkg && !posit_person_ok)
      ),
      todo("`usethis::use_tidy_logo(); pkgdown::build_favicons(overwrite = TRUE)`"),
      todo("`usethis::use_tidy_coc()`"),
      todo(
        "Modernize citation files; see updated `use_citation()`",
        has_citation_file()
      ),
      todo('Use `pak::pak("{repo_spec}")` in README'),
      todo("
        Consider running `usethis::use_tidy_dependencies()` and/or \\
        replace compat files with `use_standalone()`"),
      todo("Use cli errors or [file an issue](new) if you don\'t have time to do it now"),
      todo('
        `usethis::use_standalone("r-lib/rlang", "types-check")` \\
        instead of home grown argument checkers;
        or [file an issue](new) if you don\'t have time to do it now'),
      todo(
        "
        Change files ending in `.r` to `.R` in `R/` and/or `tests/testthat/`",
        lowercase_r()
      ),
      todo("
        Add alt-text to pictures, plots, etc; see \\
        https://posit.co/blog/knitr-fig-alt/ for examples"
      ),
      ""
    )
  }

  bullets <- c(
    bullets,
    "### To finish",
    "",
    todo("`usethis::use_mit_license()`", grepl("MIT", desc$get_field("License"))),
    todo(
      '`usethis::use_package("R", "Depends", "{tidy_minimum_r_version()}")`',
      tidy_minimum_r_version() > pkg_minimum_r_version()
    ),
    todo("`usethis::use_tidy_description()`"),
    todo("`usethis::use_tidy_github_actions()`"),
    todo("`devtools::build_readme()`"),
    todo("[Re-publish released site](https://pkgdown.r-lib.org/dev/articles/how-to-update-released-site.html) if needed"),
    ""
  )

  c(bullets, checklist_footer(tidy = TRUE))
}

# upkeep helpers ----------------------------------------------------------

# https://www.tidyverse.org/blog/2019/04/r-version-support/
tidy_minimum_r_version <- function() {
  con <- curl::curl("https://api.r-hub.io/rversions/r-oldrel/4")
  withr::defer(close(con))
  # I do not want a failure here to make use_tidy_upkeep_issue() fail
  json <- tryCatch(readLines(con, warn = FALSE), error = function(e) NULL)
  if (is.null(json)) {
    oldrel_4 <- "3.6"
  } else {
    version <- jsonlite::fromJSON(json)$version
    oldrel_4 <- re_match(version, "[0-9]+[.][0-9]+")$.match
  }
  numeric_version(oldrel_4)
}

lowercase_r <- function() {
  path <- proj_path(c("R", "tests"))
  path <- path[fs::dir_exists(path)]
  any(fs::path_ext(fs::dir_ls(path, recurse = TRUE)) == "r")
}

has_coc <- function() {
  path <- proj_path(c(".", ".github"), "CODE_OF_CONDUCT.md")
  any(file_exists(path))
}

has_citation_file <- function() {
  file_exists(proj_path("inst/CITATION"))
}

uses_old_testthat_edition <- function(current) {
  if (!requireNamespace("testthat", quietly = TRUE)) {
    return(FALSE)
  }
  uses_testthat() && testthat::edition_get() < current
}

upkeep_extra_bullets <- function(env = NULL) {
  env <- env %||% safe_pkg_env()

  if (env_has(env, "upkeep_bullets")) {
    c(paste0("* [ ] ", env$upkeep_bullets()), "")
  } else {
    ""
  }
}

checklist_footer <- function(tidy) {
  tidy_fun <- if (tidy) "tidy_" else ""
  glue('<sup>\\
    Created on {Sys.Date()} with `usethis::use_{tidy_fun}upkeep_issue()`, using \\
    [usethis v{usethis_version()}](https://usethis.r-lib.org)\\
    </sup>')
}

usethis_version <- function() {
  utils::packageVersion("usethis")
}

has_old_cran_comments <- function() {
  cc <- proj_path("cran-comments.md")
  file_exists(cc) &&
    any(grepl("# test environment", readLines(cc), ignore.case = TRUE))
}
