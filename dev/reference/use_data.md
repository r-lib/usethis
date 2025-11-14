# Create package data

`use_data()` makes it easy to save package data in the correct format. I
recommend you save scripts that generate package data in `data-raw`: use
`use_data_raw()` to set it up. You also need to document exported
datasets.

## Usage

``` r
use_data(
  ...,
  internal = FALSE,
  overwrite = FALSE,
  compress = "bzip2",
  version = 3,
  ascii = FALSE
)

use_data_raw(name = "DATASET", open = rlang::is_interactive())
```

## Arguments

- ...:

  Unquoted names of existing objects to save.

- internal:

  If `FALSE`, saves each object in its own `.rda` file in the `data/`
  directory. These data files bypass the usual export mechanism and are
  available whenever the package is loaded (or via
  [`data()`](https://rdrr.io/r/utils/data.html) if `LazyData` is not
  true).

  If `TRUE`, stores all objects in a single `R/sysdata.rda` file.
  Objects in this file follow the usual export rules. Note that this
  means they will be exported if you are using the common
  `exportPattern()` rule which exports all objects except for those that
  start with `.`.

- overwrite:

  By default, `use_data()` will not overwrite existing files. If you
  really want to do so, set this to `TRUE`.

- compress:

  Choose the type of compression used by
  [`save()`](https://rdrr.io/r/base/save.html). Should be one of "gzip",
  "bzip2", or "xz".

- version:

  The serialization format version to use. The default, 3, can only be
  read by R versions 3.5.0 and higher. For R 1.4.0 to 3.5.3, use version
  2.

- ascii:

  if `TRUE`, an ASCII representation of the data is written. The default
  value of `ascii` is `FALSE` which leads to a binary file being
  written. If `NA` and `version >= 2`, a different ASCII representation
  is used which writes double/complex numbers as binary fractions.

- name:

  Name of the dataset to be prepared for inclusion in the package.

- open:

  Open the newly created file for editing? Happens in RStudio, if
  applicable, or via
  [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
  otherwise.

## See also

The [data chapter](https://r-pkgs.org/data.html) of [R
Packages](https://r-pkgs.org).

## Examples

``` r
if (FALSE) { # \dontrun{
x <- 1:10
y <- 1:100

use_data(x, y) # For external use
use_data(x, y, internal = TRUE) # For internal use
} # }
if (FALSE) { # \dontrun{
use_data_raw("daisy")
} # }
```
