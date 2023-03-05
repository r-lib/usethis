# upkeep bullets don't change accidentally

    Code
      writeLines(upkeep_checklist(rstudio_pkg = TRUE, rstudio_person_ok = FALSE))
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
      The docs for `usethis::use_r()` include a helpful script.
      `usethis::rename_files()` may be be useful.
      
      2021
      
      * [ ] `usethis::use_tidy_dependencies()`
      * [ ] `usethis::use_tidy_github_actions()` and update artisanal actions to use `setup-r-dependencies`
      * [ ] Remove check environments section from `cran-comments.md`
      * [ ] Bump required R version in DESCRIPTION to 3.5
      * [ ] Use lifecycle instead of artisanal deprecation messages, as described in [Communicate lifecycle changes in your functions](https://lifecycle.r-lib.org/articles/communicate.html)
      * [ ] Make sure RStudio appears in `Authors@R` of DESCRIPTION like so, if appropriate:
      `person("RStudio", role = c("cph", "fnd"))`
      
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
      * [ ] Update lifecycle badges with more accessible SVGs: `usethis::use_lifecycle()`
      
      2023
      
      Posit updates:
      
      * [ ] Update copyright holder in DESCRIPTION:
      `person(given = "Posit, PBC", role = c("cph", "fnd"))`
      * [ ] Double check license file uses '[package] authors' as copyright holder. Run `use_mit_license()`
      * [ ] Update email addresses *@rstudio.com -> *@posit.co
      * [ ] `usethis::use_tidy_coc()`
      
      * [ ] Review 2022 checklist to see if you completed the pkgdown updates
      
      * [ ] Update logo (https://github.com/rstudio/hex-stickers); run `use_tidy_logo()`
      * [ ] Use `pak::pkg_install("org/pkg") in README
      * [ ] Consider running `use_tidy_dependencies()` and/or replace compat files with `use_standalone()`
      * [ ] `use_standalone("r-lib/rlang", "types-check")` instead of home grown argument checkers
      * [ ] Add alt-text to pictures, plots, etc; see https://www.rstudio.com/blog/knitr-fig-alt/ for examples
      

