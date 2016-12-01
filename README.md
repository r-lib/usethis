# usethis

[![Travis build status](https://travis-ci.org/r-pkgs/usethis.svg?branch=master)](https://travis-ci.org/r-pkgs/usethis)
[![Coverage status](https://img.shields.io/codecov/c/github/r-pkgs/usethis/master.svg)](https://codecov.io/github/r-pkgs/usethis?branch=master)

The goal of usethis is to automate many common package and analysis setup tasks.

## Installation

You can install usethis from github with:

``` r
# install.packages("devtools")
devtools::install_github("r-pkgs/usethis")
```

## Usage

All `use_*` functions operate on the current directory.

``` r
use_test("my-test")
use_github()
use_rcpp()
```
