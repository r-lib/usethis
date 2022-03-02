# upkeep bullets don't change accidentally

    Code
      writeLines(upkeep_checklist())
    Output
      Pre-history
      
      * [ ] `usethis::use_readme_rmd()`
      * [ ] `usethis::use_roxygen_md()`
      * [ ] `usethis::use_github_links()`
      * [ ] `usethis::use_pkgdown_github_pages()`
      * [ ] `usethis::use_tidy_github_labels()`
      * [ ] `usethis::use_tidy_style()`
      * [ ] `usethis::use_tidy_description()`
      * [ ] `urlchecker::url_check()`
      
      2020
      
      * [ ] `usethis::use_package_doc()`
      Consider letting usethis manage your `@importFrom` directives here.
      `usethis::use_import_from()` is handy for this.
      * [ ] `usethis::use_testthat(3)` and upgrade to 3e, [testthat 3e vignette](https://testthat.r-lib.org/articles/third-edition.html)
      * [ ] Align the names of `R/` files and `test/` files for workflow happiness.
      `usethis::rename_files()` can be helpful.
      
      2021
      
      * [ ] `usethis::use_tidy_dependencies()`
      * [ ] `usethis::use_tidy_github_actions()` and update artisanal actions to use `setup-r-dependencies`
      * [ ] Remove check environments section from `cran-comments.md`
      * [ ] Bump required R version in DESCRIPTION to 3.4
      * [ ] Use lifecycle instead of artisanal deprecation messages, as described in [Communicate lifecycle changes in your functions](https://lifecycle.r-lib.org/articles/communicate.html)
      
      2022
      
      * [ ] `usethis::use_tidy_coc()`
      * [ ] Handle and close any still-open `master` --> `main` issues
      * [ ] Update README badges, instructions in [r-lib/usethis#1594](https://github.com/r-lib/usethis/issues/1594)
      * [ ] Update errors to rlang 1.0.0. Helpful guides:
      <https://rlang.r-lib.org/reference/topic-error-call.html>
      <https://rlang.r-lib.org/reference/topic-error-chaining.html>
      <https://rlang.r-lib.org/reference/topic-condition-formatting.html>
      * [ ] Update pkgdown site using instructions at <https://tidytemplate.tidyverse.org>
      * [ ] Ensure pkgdown `development` is `mode: auto` in pkgdown config
      * [ ] Re-publish released site; see [How to update a released site](https://pkgdown.r-lib.org/dev/articles/how-to-update-released-site.html)
      

