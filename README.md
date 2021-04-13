
<!-- README.md is generated from README.Rmd. Please edit that file -->

# usethis <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-lib/usethis/workflows/R-CMD-check/badge.svg)](https://github.com/r-lib/usethis/actions)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/usethis/branch/master/graph/badge.svg)](https://codecov.io/gh/r-lib/usethis?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/usethis)](https://CRAN.R-project.org/package=usethis)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

usethis is a workflow package: it automates repetitive tasks that arise
during project setup and development, both for R packages and
non-package projects.

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

Most `use_*()` functions operate on the *active project*: literally, a
directory on your computer. If you’ve just used usethis to create a new
package or project, that will be the active project. Otherwise, usethis
verifies that current working directory is or is below a valid project
directory and that becomes the active project. Use `proj_get()` or
`proj_sitrep()` to manually query the project and [read more in the
docs](https://usethis.r-lib.org/reference/proj_utils.html).

A few usethis functions have no strong connections to projects and will
expect you to provide a path.

usethis is quite chatty, explaining what it’s doing and assigning you
tasks. `✔` indicates something usethis has done for you. `●` indicates
that you’ll need to do some work yourself.

Below is a quick look at how usethis can help to set up a package. But
remember, many usethis functions are also applicable to analytical
projects that are not packages.

``` r
library(usethis)

# Create a new package -------------------------------------------------
path <- file.path(tempdir(), "mypkg")
create_package(path)
#> ✓ Creating '/var/folders/03/9x7925g54mncswxx06wpkxl00000gn/T/RtmpxLZ8U3/mypkg/'
#> ✓ Setting active project to '/private/var/folders/03/9x7925g54mncswxx06wpkxl00000gn/T/RtmpxLZ8U3/mypkg'
#> ✓ Creating 'R/'
#> ✓ Writing 'DESCRIPTION'
#> Package: mypkg
#> Title: What the Package Does (One Line, Title Case)
#> Version: 0.0.0.9000
#> Authors@R (parsed):
#>     * First Last <first.last@example.com> [aut, cre] (YOUR-ORCID-ID)
#> Description: What the package does (one paragraph).
#> License: `use_mit_license()`, `use_gpl3_license()` or friends to pick a
#>     license
#> Encoding: UTF-8
#> Roxygen: list(markdown = TRUE)
#> RoxygenNote: 7.1.1
#> ✓ Writing 'NAMESPACE'
#> ✓ Setting active project to '<no active project>'
# only needed since this session isn't interactive
proj_activate(path)
#> ✓ Setting active project to '/private/var/folders/03/9x7925g54mncswxx06wpkxl00000gn/T/RtmpxLZ8U3/mypkg'
#> ✓ Changing working directory to '/var/folders/03/9x7925g54mncswxx06wpkxl00000gn/T/RtmpxLZ8U3/mypkg/'

# Modify the description ----------------------------------------------
use_mit_license("My Name")
#> ✓ Setting License field in DESCRIPTION to 'MIT + file LICENSE'
#> ✓ Writing 'LICENSE'
#> ✓ Writing 'LICENSE.md'
#> ✓ Adding '^LICENSE\\.md$' to '.Rbuildignore'

use_package("MASS", "Suggests")
#> ✓ Adding 'MASS' to Suggests field in DESCRIPTION
#> ● Use `requireNamespace("MASS", quietly = TRUE)` to test if package is installed
#> ● Then directly refer to functons like `MASS::fun()` (replacing `fun()`).

# Set up other files -------------------------------------------------
use_readme_md()
#> ✓ Writing 'README.md'

use_news_md()
#> ✓ Writing 'NEWS.md'

use_test("my-test")
#> ✓ Adding 'testthat' to Suggests field in DESCRIPTION
#> ✓ Setting Config/testthat/edition field in DESCRIPTION to '3'
#> ✓ Creating 'tests/testthat/'
#> ✓ Writing 'tests/testthat.R'
#> ✓ Writing 'tests/testthat/test-my-test.R'
#> ● Edit 'tests/testthat/test-my-test.R'

x <- 1
y <- 2
use_data(x, y)
#> ✓ Adding 'R' to Depends field in DESCRIPTION
#> ✓ Creating 'data/'
#> ✓ Setting LazyData to 'true' in 'DESCRIPTION'
#> ✓ Saving 'x', 'y' to 'data/x.rda', 'data/y.rda'
#> ● Document your data (see 'https://r-pkgs.org/data.html')

# Use git ------------------------------------------------------------
use_git()
#> ✓ Initialising Git repo
#> ✓ Adding '.Rproj.user', '.Rhistory', '.Rdata', '.httr-oauth', '.DS_Store' to '.gitignore'
```

## Code of Conduct

Please note that the usethis project is released with a [Contributor
Code of Conduct](https://usethis.r-lib.org/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.
