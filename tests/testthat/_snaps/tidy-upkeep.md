# upkeep bullets don't change accidentally

    Code
      cat(upkeep_checklist(), sep = "\n")
    Output
      Pre-history
      
      * [ ] `usethis::use_readme_rmd()`
      * [ ] `usethis::use_roxygen_md()`
      * [ ] `usethis::use_pkgdown_github_pages()` + `usethis::use_github_links()`
      * [ ] `usethis::use_tidy_labels()`
      * [ ] `urlchecker::url_check()`
      * [ ] `usethis::use_tidy_style()`
      * [ ] `usethis::use_tidy_description()`
      
      2020
      
      * [ ] `usethis::use_package_doc()`
      * [ ] `usethis::use_testthat(3)` and upgrade to 3e
      * [ ] Check that all `test/` files have corresponding `R/` file. Remember `usethis::rename_files()` exists.
      
      2021
      
      * [ ] `usethis::use_tidy_dependencies()`
      * [ ] `usethis::use_tidy_github_actions()` and update artisanal actions to use `setup-r-dependencies`
      * [ ] Remove check environments section from `cran-comments.md`
      * [ ] Bump required R version in DESCRIPTION to 3.4
      * [ ] Use lifecycle instead of artisanal deprecation messages
      

