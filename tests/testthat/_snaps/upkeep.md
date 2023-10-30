# tidy upkeep bullets don't change accidentally

    Code
      writeLines(tidy_upkeep_checklist(posit_pkg = TRUE, posit_person_ok = FALSE))
    Output
      ### Pre-history
      
      * [ ] `usethis::use_readme_rmd()`
      * [ ] `usethis::use_roxygen_md()`
      * [ ] `usethis::use_github_links()`
      * [ ] `usethis::use_pkgdown_github_pages()`
      * [ ] `usethis::use_tidy_github_labels()`
      * [ ] `usethis::use_tidy_style()`
      * [ ] `urlchecker::url_check()`
      
      ### 2020
      
      * [ ] `usethis::use_package_doc()`
      * [ ] `usethis::use_testthat(3)`
      * [ ] Align the names of `R/` files and `test/` files
      
      ### 2021
      
      * [ ] Remove check environments section from `cran-comments.md`
      * [ ] Use lifecycle instead of artisanal deprecation messages
      
      ### 2022
      
      * [ ] Handle and close any still-open `master` --> `main` issues
      * [ ] `usethis:::use_codecov_badge("OWNER/REPO")`
      * [ ] Update pkgdown site using instructions at <https://tidytemplate.tidyverse.org>
      * [ ] Update lifecycle badges with more accessible SVGs: `usethis::use_lifecycle()`
      
      ### 2023
      
      * [ ] Update email addresses *@rstudio.com -> *@posit.co
      * [ ] Update copyright holder in DESCRIPTION: `person("Posit Software, PBC", role = c("cph", "fnd"))`
      * [ ] `Run devtools::document()` to re-generate package-level help topic with DESCRIPTION changes
      * [ ] `usethis::use_tidy_logo()`
      * [ ] `usethis::use_tidy_coc()`
      * [ ] Use `pak::pak("org/pkg")` in README
      * [ ] Consider running `usethis::use_tidy_dependencies()` and/or replace compat files with `use_standalone()`
      * [ ] Use cli errors or [file an issue](new) if you don't have time to do it now
      * [ ] `usethis::use_standalone("r-lib/rlang", "types-check")` instead of home grown argument checkers;
      or [file an issue](new) if you don't have time to do it now
      * [ ] Add alt-text to pictures, plots, etc; see https://posit.co/blog/knitr-fig-alt/ for examples
      
      ### Eternal
      
      * [ ] `usethis::use_mit_license()`
      * [ ] `usethis::use_package("R", "Depends", "3.6")`
      * [ ] `usethis::use_tidy_description()`
      * [ ] `usethis::use_tidy_github_actions()`
      * [ ] `devtools::build_readme()`
      * [ ] [Re-publish released site](https://pkgdown.r-lib.org/dev/articles/how-to-update-released-site.html) if needed
      
      <sup>Created on DATE with `usethis::use_tidy_upkeep_issue()`, using [usethis vVERSION](https://usethis.r-lib.org)</sup>

# upkeep bullets don't change accidentally

    Code
      writeLines(upkeep_checklist())
    Output
      * [ ] `usethis::use_readme_rmd()`
      * [ ] `usethis::use_github_links()`
      * [ ] `usethis::use_pkgdown_github_pages()`
      * [ ] `usethis::use_tidy_description()`
      * [ ] `usethis::use_package_doc()`
      Consider letting usethis manage your `@importFrom` directives here. `usethis::use_import_from()` is handy for this.
      * [ ] `usethis::use_testthat()`. Learn more about testing at <https://r-pkgs.org/tests.html>
      * [ ] Align the names of `R/` files and `test/` files for workflow happiness. The docs for `usethis::use_r()` include a helpful script. `usethis::rename_files()` may be be useful.
      * [ ] `usethis::use_code_of_conduct()`
      * [ ] Add alt-text to pictures, plots, etc; see <https://posit.co/blog/knitr-fig-alt/> for examples
      
      Set up or update GitHub Actions. \
            Updating workflows to the latest version will often fix troublesome actions:
      * [ ] `usethis::use_github_action('check-standard')`
      
      <sup>Created on DATE with `usethis::use_upkeep_issue()`, using [usethis vVERSION](https://usethis.r-lib.org)</sup>

---

    Code
      local_edition(2L)
      writeLines(upkeep_checklist())
    Output
      * [ ] `usethis::use_readme_rmd()`
      * [ ] `usethis::use_github_links()`
      * [ ] `usethis::use_pkgdown_github_pages()`
      * [ ] `usethis::use_tidy_description()`
      * [ ] `usethis::use_package_doc()`
      Consider letting usethis manage your `@importFrom` directives here. `usethis::use_import_from()` is handy for this.
      * [ ] `usethis::use_testthat(3)` and upgrade to 3e, [testthat 3e vignette](https://testthat.r-lib.org/articles/third-edition.html)
      * [ ] Align the names of `R/` files and `test/` files for workflow happiness. The docs for `usethis::use_r()` include a helpful script. `usethis::rename_files()` may be be useful.
      * [ ] Consider changing default branch from `master` to `main`
      * [ ] Remove description of test environments from `cran-comments.md`.
      See `usethis::use_cran_comments()`.
      * [ ] Add alt-text to pictures, plots, etc; see <https://posit.co/blog/knitr-fig-alt/> for examples
      
      Set up or update GitHub Actions. \
            Updating workflows to the latest version will often fix troublesome actions:
      * [ ] `usethis::use_github_action('check-standard')`
      * [ ] `usethis::use_github_action('test-coverage')`
      
      <sup>Created on DATE with `usethis::use_upkeep_issue()`, using [usethis vVERSION](https://usethis.r-lib.org)</sup>

