# Create or edit R or test files

This pair of functions makes it easy to create paired R and test files,
using the convention that the tests for `R/foofy.R` should live in
`tests/testthat/test-foofy.R`. You can use them to create new files from
scratch by supplying `name`, or if you use RStudio, you can call to
create (or navigate to) the companion file based on the currently open
file. This also works when a test snapshot file is active, i.e. if
you're looking at `tests/testthat/_snaps/foofy.md`, `use_r()` or
`use_test()` take you to `R/foofy.R` or `tests/testthat/test-foofy.R`,
respectively.

## Usage

``` r
use_r(name = NULL, open = rlang::is_interactive())

use_test(name = NULL, open = rlang::is_interactive())
```

## Arguments

- name:

  Either a string giving a file name (without directory) or `NULL` to
  take the name from the currently open file in RStudio.

- open:

  Whether to open the file for interactive editing.

## Renaming files in an existing package

Here are some tips on aligning file names across `R/` and
`tests/testthat/` in an existing package that did not necessarily follow
this convention before.

This script generates a data frame of `R/` and test files that can help
you identify missed opportunities for pairing:

    library(fs)
    library(tidyverse)

    bind_rows(
      tibble(
        type = "R",
        path = dir_ls("R/", regexp = "\\.[Rr]$"),
        name = as.character(path_ext_remove(path_file(path))),
      ),
      tibble(
        type = "test",
        path = dir_ls("tests/testthat/", regexp = "/test[^/]+\\.[Rr]$"),
        name = as.character(path_ext_remove(str_remove(path_file(path), "^test[-_]"))),
      )
    ) |>
      pivot_wider(names_from = type, values_from = path) |>
      print(n = Inf)

The
[`rename_files()`](https://usethis.r-lib.org/dev/reference/rename_files.md)
function can also be helpful.

## See also

- The [testing](https://r-pkgs.org/testing-basics.html) and [R
  code](https://r-pkgs.org/code.html) chapters of [R
  Packages](https://r-pkgs.org).

- [`use_test_helper()`](https://usethis.r-lib.org/dev/reference/use_test_helper.md)
  to create a testthat helper file.

## Examples

``` r
if (FALSE) { # \dontrun{
# create a new .R file below R/
use_r("coolstuff")

# if `R/coolstuff.R` is active in a supported IDE, you can now do:
use_test()

# if `tests/testthat/test-coolstuff.R` is active in a supported IDE, you can
# return to `R/coolstuff.R` with:
use_r()
} # }
```
