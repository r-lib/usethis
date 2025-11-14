# Create or edit a test helper file

This function creates (or opens) a test helper file, typically
`tests/testthat/helper.R`. Test helper files are executed at the
beginning of every automated test run and are also executed by
[`load_all()`](https://pkgload.r-lib.org/reference/load_all.html). A
helper file is a great place to define test helper functions for use
throughout your test suite, such as a custom expectation.

## Usage

``` r
use_test_helper(name = NULL, open = rlang::is_interactive())
```

## Arguments

- name:

  Can be used to specify the optional "SLUG" in
  `tests/testthat/helper-SLUG.R`.

- open:

  Whether to open the file for interactive editing.

## See also

- [`use_test()`](https://usethis.r-lib.org/dev/reference/use_r.md) to
  create a test file.

- The testthat vignette on special files
  [`vignette("special-files", package = "testthat")`](https://testthat.r-lib.org/articles/special-files.html).

## Examples

``` r
if (FALSE) { # \dontrun{
use_test_helper()
use_test_helper("mocks")
} # }
```
