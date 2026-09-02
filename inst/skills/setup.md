# Package setup

When setting up a package for the first time, prefer using usethis functions rather than memorised solution. 

In general, you will want to follow these steps.

* Call `usethis::use_testthat()` to set up unit tests
* Call `devtools::document()` to generate `NAMESPACE` and update docs
* Ask the user which license they want to use, then call `usethis::use_mit_license()`, `usethis::use_proprietary_license()` etc.
* Create package documentation with `usethis::use_package_doc()`.
* Take a dependency on rlang with `usethis::use_package("rlang")`. Import all functions from rlang into the `NAMESPACE` with `@import rlang`.
* Call `use_news_md()` to set up a news file.
* Check the package with `devtools::check()` and ensure there are no issues
* Make an initial git commit
