# usethis

[![Travis build status](https://travis-ci.org/r-lib/usethis.svg?branch=master)](https://travis-ci.org/r-lib/usethis)
[![Coverage status](https://codecov.io/gh/r-lib/usethis/branch/master/graph/badge.svg)](https://codecov.io/github/r-lib/usethis?branch=master)
[![CRAN status](http://www.r-pkg.org/badges/version/usethis)](https://cran.r-project.org/package=usethis)

The goal of usethis is to automate many common package and analysis setup tasks.

## Installation

You can install usethis from github with:

``` r
# install.packages("devtools")
devtools::install_github("r-lib/usethis")
```

## Usage

All `use_*` functions operate on the current directory.

```r
# Create a new package
tmp <- tempfile()
create_package(tmp, open = FALSE)

# Modify the description
use_mit_license("RStudio", base_path = tmp)
use_package("MASS", "Suggests", base_path = tmp)
use_dev_package("callr", base_path = tmp)
use_dev_version(base_path = tmp)

# Set up various packages
use_rcpp(tmp)
use_roxygen_md(tmp)
use_revdep(tmp)

# Set up other files
use_readme_md(base_path = tmp)
use_news_md(base_path = tmp)
x <- 1
y <- 2
use_data(x, y, base_path = tmp)

# use git
use_git(base_path = tmp)
```
