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
#' @details
#' The following checklist will be created. Please note that some checklist
#' items may not apply to your specific package.
#'
#'
#' * usethis::use_readme_rmd()
#' * usethis::use_roxygen_md()
#' * usethis::use_github_links()
#' * usethis::use_pkgdown_github_pages()
#' * Consider using Bootstrap 5 in your pkgdown site.
#'    + See <https://pkgdown.r-lib.org/articles/customise.html> for more info
#' * usethis::use_tidy_description()
#' * usethis::use_tidy_description()
#'    + Consider letting usethis manage your `@importFrom` directives here.
#'    + usethis::use_import_from() is handy for this.
#' * usethis::use_testthat()
#' * usethis::use_testthat(3)
#' * Align the names of `R/` files and `test/` files for workflow happiness.
#'    + The docs for `usethis::use_r()` include a helpful script.
#'    + usethis::rename_files() may be be useful.
#' * Consider changing default branch from `master` to `main`
#' * usethis::use_code_of_conduct()
#' * Remove description of test environments from cran-comments.md
#'    + See usethis::use_cran_comments()
#' * Add alt-text to pictures, plots, etc
#'    + see <https://posit.co/blog/knitr-fig-alt/> for examples
#'    + Set up or update GitHub Actions.
#'    + Updating workflows to the latest version will often fix troublesome actions
#' * usethis::use_github_action('check-standard')
#' * usethis::use_github_action('pkgdown')
#' * usethis::use_github_action('test-coverage')
#'
#'
#'
#'
#'
#'
#' @param year Year you are performing the upkeep, used in the issue title.
#'   Defaults to current year
#'
#' @export
#' @examples
#' \dontrun{
#' use_upkeep_issue()
#' }
use_upkeep_issue <- function(year = NULL) {
  make_upkeep_issue(year = year, tidy = FALSE)
}

make_upkeep_issue <- function(year, last_upkeep, tidy) {
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
    checklist <- tidy_upkeep_checklist(last_upkeep, repo_spec = tr$repo_spec)
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
    todo(
      "
      Consider using Bootstrap 5 in your pkgdown site. \\
      Read more in the [pkgdown customisation article](https://pkgdown.r-lib.org/articles/customise.html).",
      uses_pkgdown() && !uses_pkgdown_bootstrap_version(5)
    ),
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
    todo(
      "
      Align the names of `R/` files and `test/` files for workflow happiness. \\
      The docs for `usethis::use_r()` include a helpful script. \\
      `usethis::rename_files()` may be be useful."
    ),
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
    todo(
      "
      Add alt-text to pictures, plots, etc; see \\
      <https://posit.co/blog/knitr-fig-alt/> for examples"
    ),
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
#' @param last_upkeep Year of last upkeep. By default, the
#' `Config/usethis/last-upkeep` field in `DESCRIPTION` is consulted for this, if
#' it's defined. If there's no information on the last upkeep, the issue will
#' contain the full checklist.
use_tidy_upkeep_issue <- function(last_upkeep = last_upkeep_year()) {
  make_upkeep_issue(year = NULL, last_upkeep = last_upkeep, tidy = TRUE)
  record_upkeep_date(Sys.Date())
}

# for mocking
Sys.Date <- NULL

tidy_upkeep_checklist <- function(
  last_upkeep = last_upkeep_year(),
  repo_spec = "OWNER/REPO"
) {
  desc <- proj_desc()

  posit_pkg <- is_posit_pkg()
  posit_person_ok <- is_posit_person_canonical()

  bullets <- c(
    "### To begin",
    "",
    todo('`usethis::pr_init("upkeep-{format(Sys.Date(), "%Y-%m")}")`'),
    ""
  )

  if (last_upkeep <= 2000) {
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
  if (last_upkeep <= 2020) {
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
  if (last_upkeep <= 2021) {
    bullets <- c(
      bullets,
      "### 2021",
      "",
      todo("Remove check environments section from `cran-comments.md`"),
      todo("Use lifecycle instead of artisanal deprecation messages"),
      ""
    )
  }
  if (last_upkeep <= 2022) {
    bullets <- c(
      bullets,
      "### 2022",
      "",
      todo("Handle and close any still-open `master` --> `main` issues"),
      todo('`usethis:::use_codecov_badge("{repo_spec}")`'),
      todo(
        "Update pkgdown site using instructions at <https://tidytemplate.tidyverse.org>"
      ),
      todo(
        "Update lifecycle badges with more accessible SVGs: `usethis::use_lifecycle()`"
      ),
      ""
    )
  }

  if (last_upkeep <= 2023) {
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
      todo(
        "`usethis::use_tidy_logo(); pkgdown::build_favicons(overwrite = TRUE)`"
      ),
      todo("`usethis::use_tidy_coc()`"),
      todo(
        "Modernize citation files; see updated `use_citation()`",
        has_citation_file()
      ),
      todo('Use `pak::pak("{repo_spec}")` in README'),
      todo(
        "
        Consider running `usethis::use_tidy_dependencies()` and/or \\
        replace compat files with `use_standalone()`"
      ),
      todo(
        "Use cli errors or [file an issue](new) if you don\'t have time to do it now"
      ),
      todo(
        '
        `usethis::use_standalone("r-lib/rlang", "types-check")` \\
        instead of home grown argument checkers;
        or [file an issue](new) if you don\'t have time to do it now'
      ),
      todo(
        "
        Change files ending in `.r` to `.R` in `R/` and/or `tests/testthat/`",
        lowercase_r()
      ),
      todo(
        "
        Add alt-text to pictures, plots, etc; see \\
        https://posit.co/blog/knitr-fig-alt/ for examples"
      ),
      ""
    )
  }

  if (last_upkeep <= 2025) {
    bullets <- c(
      bullets,
      "### 2025",
      "",
      todo("`usethis::use_air()` <https://posit-dev.github.io/air/>"),
      todo('`usethis::use_package("R", "Depends", "4.1")`'),
      todo("Switch to the base pipe (`|>`)"),
      todo("Switch to the base anonymous function syntax (`\\(x)`) "),
      todo(
        '
        Add ROR for Posit in `DESCRIPTION`:
        `person("Posit Software, PBC", role = c("cph", "fnd"), comment = c(ROR = "03wc8by49"))`',
        posit_pkg && !posit_person_ok
      ),
      todo(
        '
        Convert in-header chunk options to the newer in-body style used by Quarto:
        `fs::dir_ls("vignettes", regexp = "[.][Rq]md$") |> purrr::walk(\\(x) knitr::convert_chunk_header(x, output = identity, type = "yaml"))`
        '
      ),
      todo(
        "Switch to `expect_snapshot(error = TRUE)` instead of calling `expect_error()` without specifying `class =`"
      ),
      ""
    )
  }

  minimum_r_version <- pkg_minimum_r_version()
  bullets <- c(
    bullets,
    "### To finish",
    "",
    # TODO: if the most recent year doesn't nudge about the minimum R version,
    # re-introduce that todo()
    #
    # todo(
    #   '`usethis::use_package("R", "Depends", "{tidy_minimum_r_version()}")`',
    #   is.na(minimum_r_version) || tidy_minimum_r_version() > minimum_r_version
    # ),
    todo(
      "`usethis::use_mit_license()`",
      grepl("MIT", desc$get_field("License"))
    ),
    todo("`usethis::use_tidy_description()`"),
    todo("`usethis::use_tidy_github_actions()`"),
    todo("`devtools::build_readme()`"),
    todo(
      "
      Add alt-text to pictures, plots, etc; see \\
      https://posit.co/blog/knitr-fig-alt/ for examples"
    ),
    todo(
      "[Re-publish released site](https://pkgdown.r-lib.org/dev/articles/how-to-update-released-site.html) if needed"
    ),
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
  glue(
    '<sup>\\
    Created on {Sys.Date()} with `usethis::use_{tidy_fun}upkeep_issue()`, using \\
    [usethis v{usethis_version()}](https://usethis.r-lib.org)\\
    </sup>'
  )
}

usethis_version <- function() {
  utils::packageVersion("usethis")
}

has_old_cran_comments <- function() {
  cc <- proj_path("cran-comments.md")
  file_exists(cc) &&
    any(grepl("# test environment", readLines(cc), ignore.case = TRUE))
}

last_upkeep_date <- function() {
  as.Date(
    proj_desc()$get_field("Config/usethis/last-upkeep", "2000-01-01"),
    format = "%Y-%m-%d"
  )
}

last_upkeep_year <- function() {
  as.integer(format(last_upkeep_date(), "%Y"))
}

record_upkeep_date <- function(date) {
  proj_desc_field_update("Config/usethis/last-upkeep", format(date, "%Y-%m-%d"))
}
