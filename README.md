
<!-- README.md is generated from README.Rmd. Please edit that file -->

# usethis

[![Travis build
status](https://travis-ci.org/r-lib/usethis.svg?branch=master)](https://travis-ci.org/r-lib/usethis)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/r-lib/usethis?branch=master&svg=true)](https://ci.appveyor.com/project/r-lib/usethis)
[![Coverage
status](https://codecov.io/gh/r-lib/usethis/branch/master/graph/badge.svg)](https://codecov.io/github/r-lib/usethis?branch=master)
[![CRAN
status](http://www.r-pkg.org/badges/version/usethis)](https://cran.r-project.org/package=usethis)
[![lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)

The goal of usethis is to automate many common package and analysis
setup tasks.

## Installation

Install the released version of usethis from CRAN:

``` r
install.packages("usethis")
```

Or install the development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("r-lib/usethis")
```

## Usage

Most `use_*()` functions operate on the *active project*. If you’ve just
used usethis to create a new package or project, that will be the
current project. Otherwise usethis tries to confirm that current working
directory can be recognized as a project. Use `proj_get()` and
`proj_set()` for manual intervention. Some functions have no strong
connections to projects and will expect you to provide a path.

usethis is quite chatty, explaining what it’s doing and assigning you
tasks. `✔` indicates something usethis has done for you. `●` indicates
that you’ll need to do some work yourself.

Below is a quick look at how usethis can help to set up a package.

*Note: usethis is gaining more and more functionality for analytical
project that are not packages. Stay tuned.*

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
#> ✔ Setting RoxygenNote field in DESCRIPTION to '6.0.1.9000'
#> ● Re-document

use_rcpp()
#> ✔ Adding 'Rcpp' to LinkingTo field in DESCRIPTION
#> ✔ Adding 'Rcpp' to Imports field in DESCRIPTION*
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
#> ✔ Adding 'checks', 'library', 'checks.noindex', 'library.noindex', 'data.sqlite', '*.html' to 'revdep/.gitignore'
#> ✔ Writing 'revdep/email.yml'
#> ● Run checks with `revdepcheck::revdep_check(num_workers = 4)`

# Set up other files -------------------------------------------------
use_readme_md()
#> ✔ Writing 'README.md'

use_news_md()
#> ✔ Writing 'NEWS.md'
#> ● Edit 'NEWS.md'

use_test("my-test")
#> ✔ Adding 'testthat' to Suggests field in DESCRIPTION
#> ✔ Creating 'tests/testthat/'
#> ✔ Writing 'tests/testthat.R'
#> ✔ Writing 'tests/testthat/test-my-test.R'
#> ● Edit 'test-my-test.R'

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

Please note that this project is released with a [Contributor Code of
Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project
you agree to abide by its terms.
