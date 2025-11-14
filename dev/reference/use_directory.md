# Use a directory

`use_directory()` creates a directory (if it does not already exist) in
the project's top-level directory. This function powers many of the
other `use_` functions such as
[`use_data()`](https://usethis.r-lib.org/dev/reference/use_data.md) and
[`use_vignette()`](https://usethis.r-lib.org/dev/reference/use_vignette.md).

## Usage

``` r
use_directory(path, ignore = FALSE)
```

## Arguments

- path:

  Path of the directory to create, relative to the project.

- ignore:

  Should the newly created file be added to `.Rbuildignore`?

## Examples

``` r
if (FALSE) { # \dontrun{
use_directory("inst")
} # }
```
