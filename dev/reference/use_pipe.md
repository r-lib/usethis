# Use magrittr's pipe in your package

Does setup necessary to use magrittr's pipe operator, `%>%` in your
package. This function requires the use of roxygen2.

- Adds magrittr to "Imports" in `DESCRIPTION`.

- Imports the pipe operator specifically, which is necessary for
  internal use.

- Exports the pipe operator, if `export = TRUE`, which is necessary to
  make `%>%` available to the users of your package.

## Usage

``` r
use_pipe(export = TRUE)
```

## Arguments

- export:

  If `TRUE`, the file `R/utils-pipe.R` is added, which provides the
  roxygen template to import and re-export `%>%`. If `FALSE`, the
  necessary roxygen directive is added, if possible, or otherwise
  instructions are given.

## Examples

``` r
if (FALSE) { # \dontrun{
use_pipe()
} # }
```
