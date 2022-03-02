#' @export
#' @rdname tidyverse
#' @param year Approximate year when you last touched this package. If `NULL`,
#'   the default, will give you a full set of actions to perform.
use_tidy_upkeep_issue <- function(year = NULL) {
  check_is_package("use_tidy_upkeep_issue()")

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

  checklist <- upkeep_checklist(year)

  gh <- gh_tr(tr)
  issue <- gh(
    "POST /repos/{owner}/{repo}/issues",
    title = glue("Upkeep for {project_name()}"),
    body = paste0(checklist, "\n", collapse = "")
  )
  Sys.sleep(1)
  view_url(issue$html_url)
}

upkeep_checklist <- function(year = NULL) {
  year <- year %||% 2000
  is_rstudio_funded <- is_rstudio_funded()
  is_in_rstudio_org <- is_in_rstudio_org()
  bullets <- c()

  if (year <= 2000) {
    bullets <- c(bullets,
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
    bullets <- c(bullets,
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
        `usethis::rename_files()` can be helpful."),
      ""
    )
  }
  if (year <= 2021) {
    bullets <- c(bullets,
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
      todo("
        Add RStudio to DESCRIPTION as funder, if appropriate",
        !is_rstudio_funded && is_in_rstudio_org),
      ""
    )
  }
if (year <= 2022) {
    bullets <- c(bullets,
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
