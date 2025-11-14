# Sets up overall testing infrastructure

Creates `tests/testthat/`, `tests/testthat.R`, and adds the testthat
package to the Suggests field. Learn more in
<https://r-pkgs.org/testing-basics.html>

## Usage

``` r
use_testthat(edition = NULL, parallel = FALSE)
```

## Arguments

- edition:

  testthat edition to use. Defaults to the latest edition, i.e. the
  major version number of the currently installed testthat.

- parallel:

  Should tests be run in parallel? This feature appeared in testthat
  3.0.0; see <https://testthat.r-lib.org/articles/parallel.html> for
  details and caveats.

## See also

[`use_test()`](https://usethis.r-lib.org/dev/reference/use_r.md) to
create individual test files

## Examples

``` r
if (FALSE) { # \dontrun{
use_testthat()

use_test()

use_test("something-management")
} # }
```
