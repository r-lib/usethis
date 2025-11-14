# Use a basic `NAMESPACE`

If `roxygen` is `TRUE` generates an empty `NAMESPACE` that exports
nothing; you'll need to explicitly export functions with `@export`. If
`roxygen` is `FALSE`, generates a default `NAMESPACE` that exports all
functions except those that start with `.`.

## Usage

``` r
use_namespace(roxygen = TRUE)
```

## Arguments

- roxygen:

  Do you plan to manage `NAMESPACE` with roxygen2?

## See also

The [namespace
chapter](https://r-pkgs.org/dependencies-mindset-background.html#sec-dependencies-namespace)
of [R Packages](https://r-pkgs.org).
