# tidy upkeep bullets don't change accidentally

    Code
      writeLines(tidy_upkeep_checklist())
    Output
      ### To begin
      
      * [ ] `pr_init("upkeep-2023-01")`
      
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
      * [ ] Run `devtools::document()` to re-generate package-level help topic with DESCRIPTION changes
      * [ ] `usethis::use_tidy_logo(); pkgdown::build_favicons(overwrite = TRUE)`
      * [ ] `usethis::use_tidy_coc()`
      * [ ] Use `pak::pak("OWNER/REPO")` in README
      * [ ] Consider running `usethis::use_tidy_dependencies()` and/or replace compat files with `use_standalone()`
      * [ ] Use cli errors or [file an issue](new) if you don't have time to do it now
      * [ ] `usethis::use_standalone("r-lib/rlang", "types-check")` instead of home grown argument checkers;
      or [file an issue](new) if you don't have time to do it now
      * [ ] Add alt-text to pictures, plots, etc; see https://posit.co/blog/knitr-fig-alt/ for examples
      
      ### To finish
      
      * [ ] `usethis::use_mit_license()`
      * [ ] `usethis::use_package("R", "Depends", "4.0")`
      * [ ] `usethis::use_tidy_description()`
      * [ ] `usethis::use_tidy_github_actions()`
      * [ ] `devtools::build_readme()`
      * [ ] [Re-publish released site](https://pkgdown.r-lib.org/dev/articles/how-to-update-released-site.html) if needed
      
      <sup>Created on 2023-01-01 with `usethis::use_tidy_upkeep_issue()`, using [usethis v1.1.0](https://usethis.r-lib.org)</sup>

