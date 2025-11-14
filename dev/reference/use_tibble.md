# Prepare to return a tibble

**\[questioning\]**

Does minimum setup such that a tibble returned by your package is
handled using the tibble method for generics like
[`print()`](https://rdrr.io/r/base/print.html) or `[`. Presumably you
care about this if you've chosen to store and expose an object with
class `tbl_df`. Specifically:

- Check that the active package uses roxygen2

- Add the tibble package to "Imports" in `DESCRIPTION`

- Prepare the roxygen directive necessary to import at least one
  function from tibble:

  - If possible, the directive is inserted into existing package-level
    documentation, i.e. the roxygen snippet created by
    [`use_package_doc()`](https://usethis.r-lib.org/dev/reference/use_package_doc.md)

  - Otherwise, we issue advice on where the user should add the
    directive

This is necessary when your package returns a stored data object that
has class `tbl_df`, but the package code does not make direct use of
functions from the tibble package. If you do nothing, the tibble
namespace is not necessarily loaded and your tibble may therefore be
printed and subsetted like a base `data.frame`.

## Usage

``` r
use_tibble()
```

## Examples

``` r
if (FALSE) { # \dontrun{
use_tibble()
} # }
```
