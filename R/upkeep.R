#' @export
#' @rdname tidyverse
#' @param year Approximate year when you last touched this package. If `NULL`,
#'   the default, will give you a full set of actions to perform.
use_tidy_upkeep_issue <- function(year = NULL) {
  make_upkeep_issue(year = year, tidy = TRUE)
}

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
  year <- year %||% format(Sys.Date(), "%Y")
  make_upkeep_issue(year = year, tidy = FALSE)
}

make_upkeep_issue <- function(year, tidy) {

  who <- if (tidy) "use_tidy_upkeep_issue()" else "use_upkeep_issue()"
  check_is_package(who)

  tr <- target_repo(github_get = TRUE)

  if (!isTRUE(tr$can_push)) {
    ui_line("
      It is very unusual to open an upkeep issue on a repo you can't push to:
        {ui_value(tr$repo_spec)}")
    if (ui_nope("Do you really want to do this?")) {
      ui_oops("Cancelling.")
      return(invisible())
    }
  }

  checklist <- if (tidy) tidy_upkeep_checklist(year) else upkeep_checklist()

  maybe_year <- if (is.null(year)) "" else glue(" ({year})")

  gh <- gh_tr(tr)
  issue <- gh(
    "POST /repos/{owner}/{repo}/issues",
    title = glue("Upkeep for {project_name()}{maybe_year}"),
    body = paste0(checklist, "\n", collapse = "")
  )
  Sys.sleep(1)
  view_url(issue$html_url)
}

upkeep_checklist <- function() {

  bullets <- c(
    todo("`usethis::use_readme_rmd()`", !file_exists("README.Rmd")),
    todo("`usethis::use_roxygen_md()`", !is_true(uses_roxygen_md())),
    todo("`usethis::use_github_links()`", !has_github_links()),
    todo("`usethis::use_pkgdown_github_pages()`", !uses_pkgdown()),
    todo("
        `usethis::use_package_doc()`.
        Consider letting usethis manage your `@importFrom` directives here. \\
        `usethis::use_import_from()` is handy for this.",
        !has_package_doc()
    ),
    todo("
         `usethis::use_testthat()`. \\
         Learn more about testing at https://r-pkgs.org/tests.html",
         !uses_testthat()
    ),
    todo("
        `usethis::use_testthat(3)` and upgrade to 3e, \\
        [testthat 3e vignette](https://testthat.r-lib.org/articles/third-edition.html)",
        uses_old_testthat_edition(current = 3)
    ),
    todo("
        Align the names of `R/` files and `test/` files for workflow happiness. \\
        The docs for `usethis::use_r()` include a helpful script. \\
        `usethis::rename_files()` may be be useful."),
    todo("`usethis::use_github_action('check-standard')`", !uses_github_actions()),
    todo(
      "Consider changing default branch from `master` to `main`",
      git_default_branch() == "master"
    ),
    todo("`usethis::use_code_of_conduct()`", !has_coc()),
    todo(
      "Modernize citation files; see `usethis::use_citation()`",
      has_citation_file()
    ),
    todo("Remove check environments section from `cran-comments.md`"),
    todo("
        Use lifecycle instead of artisanal deprecation messages, as described \\
        in [Communicate lifecycle changes in your functions](https://lifecycle.r-lib.org/articles/communicate.html)",
        !proj_desc()$has_dep("lifecycle")),
    todo("
        Add alt-text to pictures, plots, etc; see \\
        https://posit.co/blog/knitr-fig-alt/ for examples")
  )

  c(bullets, upkeep_extra_bullets())
}

tidy_upkeep_checklist <- function(year = NULL,
                                  posit_pkg = is_posit_pkg(),
                                  posit_person_ok = is_posit_person_canonical()) {
  year <- year %||% 2000

  bullets <- c()

  if (year <= 2000) {
    bullets <- c(
      bullets,
      "Pre-history",
      "",
      todo("`usethis::use_readme_rmd()`"),
      todo("`usethis::use_roxygen_md()`"),
      todo("`usethis::use_github_links()`"),
      todo("`usethis::use_pkgdown_github_pages()`"),
      todo("`usethis::use_tidy_github_labels()`"),
      todo("`usethis::use_tidy_style()`"),
      todo("`usethis::use_tidy_description()`"),
      todo("`urlchecker::url_check()`"),
      ""
    )
  }
  if (year <= 2020) {
    bullets <- c(
      bullets,
      "2020",
      "",
      todo("
        `usethis::use_package_doc()`
        Consider letting usethis manage your `@importFrom` directives here.
        `usethis::use_import_from()` is handy for this."),
      todo("
        `usethis::use_testthat(3)` and upgrade to 3e, \\
        [testthat 3e vignette](https://testthat.r-lib.org/articles/third-edition.html)"),
      todo("
        Align the names of `R/` files and `test/` files for workflow happiness.
        The docs for `usethis::use_r()` include a helpful script.
        `usethis::rename_files()` may be be useful."),
      ""
    )
  }
  if (year <= 2021) {
    bullets <- c(
      bullets,
      "2021",
      "",
      todo("`usethis::use_tidy_description()`", year > 2000),
      todo("`usethis::use_tidy_dependencies()`"),
      todo("
        `usethis::use_tidy_github_actions()` and update artisanal actions to \\
        use `setup-r-dependencies`"),
      todo("Remove check environments section from `cran-comments.md`"),
      todo("Bump required R version in DESCRIPTION to {tidy_minimum_r_version()}"),
      todo("
        Use lifecycle instead of artisanal deprecation messages, as described \\
        in [Communicate lifecycle changes in your functions](https://lifecycle.r-lib.org/articles/communicate.html)"),
      todo('
        Make sure RStudio appears in `Authors@R` of DESCRIPTION like so, if appropriate:
        `person("RStudio", role = c("cph", "fnd"))`',
        posit_pkg && !posit_person_ok),
      ""
    )
  }
  if (year <= 2022) {
    bullets <- c(
      bullets,
      "2022",
      "",
      todo("`usethis::use_tidy_coc()`"),
      todo("Handle and close any still-open `master` --> `main` issues"),
      todo("Update README badges, instructions in [r-lib/usethis#1594](https://github.com/r-lib/usethis/issues/1594)"),
      todo("
        Update errors to rlang 1.0.0. Helpful guides:
        <https://rlang.r-lib.org/reference/topic-error-call.html>
        <https://rlang.r-lib.org/reference/topic-error-chaining.html>
        <https://rlang.r-lib.org/reference/topic-condition-formatting.html>"),
      todo("Update pkgdown site using instructions at <https://tidytemplate.tidyverse.org>"),
      todo("Ensure pkgdown `development` is `mode: auto` in pkgdown config"),
      todo("Re-publish released site; see [How to update a released site](https://pkgdown.r-lib.org/dev/articles/how-to-update-released-site.html)"),
      todo("Update lifecycle badges with more accessible SVGs: `usethis::use_lifecycle()`"),
      ""
    )
  }

  if (year <= 2023) {

    desc <- proj_desc()

    bullets <- c(
      bullets,
      "2023",
      "",
      "Necessary:",
      "",
      todo(
        "Update email addresses *@rstudio.com -> *@posit.co",
        author_has_rstudio_email()
      ),
      todo('
        Update copyright holder in DESCRIPTION: \\
        `person(given = "Posit Software, PBC", role = c("cph", "fnd"))`',
        posit_pkg && !posit_person_ok
      ),
      todo('
        `Run devtools::document()` to re-generate package-level help topic \\
        with DESCRIPTION changes',
        author_has_rstudio_email() || (posit_pkg && !posit_person_ok)
      ),
      todo("
        Double check license file uses '[package] authors' \\
        as copyright holder. Run `use_mit_license()`",
        grepl("MIT", desc$get_field("License"))
      ),
      todo("
        Update logo (https://github.com/rstudio/hex-stickers); \\
        run `use_tidy_logo()`"),
      todo("`usethis::use_tidy_coc()`"),
      todo("Modernize citation files; see updated `use_citation()`",
           has_citation_file()),
      todo("`usethis::use_tidy_github_actions()`"),
      "",
      "Optional:",
      "",
      todo("Review 2022 checklist to see if you completed the pkgdown updates"),
      todo('Prefer `pak::pak("org/pkg")` over `devtools::install_github("org/pkg")` in README'),
      todo("
        Consider running `use_tidy_dependencies()` and/or \\
        replace compat files with `use_standalone()`"),
      todo('
        `use_standalone("r-lib/rlang", "types-check")` \\
        instead of home grown argument checkers'),
      todo("
        Change files ending in `.r` to `.R` in R/ and/or tests/testthat/",
        lowercase_r()),
      todo("
        Add alt-text to pictures, plots, etc; see \\
        https://posit.co/blog/knitr-fig-alt/ for examples"),
      ""
    )
  }

  bullets
}

# https://www.tidyverse.org/blog/2019/04/r-version-support/
tidy_minimum_r_version <- function() {
  con <- curl::curl("https://api.r-hub.io/rversions/r-oldrel/4")
  withr::defer(close(con))
  # I do not want a failure here to make use_tidy_upkeep_issue() fail
  json <- tryCatch(readLines(con, warn = FALSE), error = function(e) NULL)
  if (is.null(json)) {
    oldrel_4 <- "3.4"
  } else {
    version <- jsonlite::fromJSON(json)$version
    oldrel_4 <- re_match(version, "[0-9]+[.][0-9]+")$.match
  }
  oldrel_4
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
    character()
  }
}
