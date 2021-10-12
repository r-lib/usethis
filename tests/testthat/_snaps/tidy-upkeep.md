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
      * [ ] `usethis::use_tidy_style(`)
      * [ ] `use_tidy_description()
      
      2020
      
      * [ ] use_package_doc()
      * [ ] `use_testthat(3)` and upgrade to 3e
      * [ ] Check that all `test/` files have corresponding `R/` file
      
      2021
      
      * [ ] `use_tidy_dependencies()`
      * [ ] `use_tidy_github_actions()` and update artisanal actions to use `setup-r-dependencies`
      * [ ] Remove check environments section from `cran-comments.md`
      * [ ] Bump required R version in DESCRIPTION to 3.3
      * [ ] Use lifecycle instead of artisanal deprecation messages
      

