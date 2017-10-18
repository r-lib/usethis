
<!-- README.md is generated from README.Rmd. Please edit that file -->
usethis
=======

[![Travis build status](https://travis-ci.org/r-lib/usethis.svg?branch=master)](https://travis-ci.org/r-lib/usethis) [![Coverage status](https://codecov.io/gh/r-lib/usethis/branch/master/graph/badge.svg)](https://codecov.io/github/r-lib/usethis?branch=master) [![CRAN status](http://www.r-pkg.org/badges/version/usethis)](https://cran.r-project.org/package=usethis)

The goal of usethis is to automate many common package and analysis setup tasks.

Installation
------------

You can install the development version of usethis from github with:

``` r
# install.packages("devtools")
devtools::install_github("r-lib/usethis")
```

Usage
-----

All `use_*` functions operate on the current directory unless you specify the `base_path` argument. `✔` indicates that usethis has setup everything for you. `●` indicates that you'll need to do some work yourself.

``` r
library(usethis)

# Create a new package -------------------------------------------------
tmp <- file.path(tempdir(), "mypkg")
create_package(tmp)
#> Changing active project to mypkg
#> ✔ Creating 'R/'
#> ✔ Creating 'man/'
#> ✔ Writing 'DESCRIPTION'
#> ✔ Writing 'NAMESPACE'

# Modify the description ----------------------------------------------
use_mit_license("My Name")
#> ✔ Setting License field in DESCRIPTION to 'MIT + file LICENSE'
#> ✔ Writing 'LICENSE.md'
#> ✔ Adding '^LICENSE\\.md$' to '.Rbuildignore'
#> ✔ Writing 'LICENSE'

use_package("MASS", "Suggests")
#> ✔ Adding 'MASS' to Suggests field in DESCRIPTION
#> ● Use `requireNamespace("MASS", quietly = TRUE)` to test if package is installed
#> ● Then use `MASS::fun()` to refer to functions.

use_dev_package("callr")
#> ✔ Adding 'callr' to Imports field in DESCRIPTION
#> ● Refer to functions with `callr::fun()`
#> ✔ Adding 'r-lib/callr' to DESCRIPTION Remotes

# Set up various packages ---------------------------------------------
use_roxygen_md()
#> ✔ Setting Roxygen field in DESCRIPTION to 'list(markdown = TRUE)'
#> ✔ Setting RoxygenNote field in DESCRIPTION to '6.0.1'
#> ● Re-document

use_rcpp()
#> ✔ Adding 'Rcpp' to LinkingTo field in DESCRIPTION
#> ✔ Adding 'Rcpp' to Imports field in DESCRIPTION
#> ✔ Creating 'src/'
#> ✔ Adding '*.o', '*.so', '*.dll' to 'src/.gitignore'
#> ● Include the following roxygen tags somewhere in your package
#>   #' @useDynLib mypkg, .registration = TRUE
#>   #' @importFrom Rcpp sourceCpp
#>   NULL
#> ● Run document()

use_revdep()
#> ✔ Creating 'revdep/'
#> ✔ Adding '^revdep$' to '.Rbuildignore'
#> ✔ Adding 'revdep/checks' to './.gitignore'
#> ✔ Adding 'revdep/library' to './.gitignore'
#> ✔ Writing 'revdep/email.yml'
#> ● Run checks with `revdepcheck::revdep_check(num_workers = 4)`

# Set up other files -------------------------------------------------
use_readme_md()
#> ✔ Writing 'README.md'
#> ● Edit 'README.md'

use_news_md()
#> ✔ Writing 'NEWS.md'
#> ● Edit 'NEWS.md'

use_test("my-test")
#> ✔ Adding 'testthat' to Suggests field in DESCRIPTION
#> ✔ Creating 'tests/testthat/'
#> ✔ Writing 'tests/testthat.R'
#> ✔ Writing 'tests/testthat/test-my-test.R'
#> ● Edit 'tests/testthat/test-my-test.R'

x <- 1
y <- 2
use_data(x, y)
#> ✔ Creating 'data/'
#> ✔ Saving x to data/x.rda
#> ✔ Saving y to data/y.rda

# Use git ------------------------------------------------------------
use_git()
#> ✔ Initialising Git repo
#> ✔ Adding '.Rhistory', '.RData', '.Rproj.user' to './.gitignore'
#> ✔ Adding files and committing
```
