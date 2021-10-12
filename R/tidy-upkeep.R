#' @export
#' @rdname tidyverse
#' @param year Approximate year when you last touched this package. If `NULL`,
#'   the default, will give you a full set of actions to perform.
use_tidy_upkeep_issue <- function(year = NULL) {
  check_is_package("use_tidy_upkeep_issue()")

  tr <- target_repo(github_get = TRUE)
  if (!isTRUE(tr$can_push)) {
    ui_line("
      It is very unusual to open a upkeep issue on a repo you can't push to:
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
    title = glue("Release {project_name()} {version}"),
    body = paste0(checklist, "\n", collapse = "")
  )
  view_url(issue$html_url)
}

upkeep_checklist <- function(year = NULL) {
  year <- year %||% 2000
  bullets <- c()

  if (year <= 2000) {
    bullets <- c(bullets,
      "Pre-history",
      "",
      todo("`usethis::use_readme_rmd()`"),
      todo("`usethis::use_roxygen_md()`"),
      todo("`usethis::use_pkgdown_github_pages()` + `usethis::use_github_links()`"),
      todo("`usethis::use_tidy_labels()`"),
      todo("`urlchecker::url_check()`"),
      todo("`usethis::use_tidy_style(`)"),
      todo("`use_tidy_description()"),
      ""
    )
  }
  if (year <= 2020) {
    bullets <- c(bullets,
      "2020",
      "",
      todo("use_package_doc()"),
      todo("`use_testthat(3)` and upgrade to 3e"),
      todo("Check that all `test/` files have corresponding `R/` file"),
      ""
    )
  }
  if (year <= 2021) {
    bullets <- c(bullets,
      "2021",
      "",
      todo("`use_tidy_description()", year > 2000),
      todo("`use_tidy_dependencies()`"),
      todo("`use_tidy_github_actions()` and update artisanal actions to use `setup-r-dependencies`"),
      todo("Remove check environments section from `cran-comments.md`"),
      todo("Bump required R version in DESCRIPTION to 3.3"),
      todo("Use lifecycle instead of artisanal deprecation messages"),
      ""
    )
  }

  bullets
}
