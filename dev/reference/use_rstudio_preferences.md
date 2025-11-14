# Set global RStudio preferences

This function allows you to set global RStudio preferences, achieving
the same effect programmatically as clicking buttons in RStudio's Global
Options. You can find a list of configurable properties at
<https://docs.posit.co/ide/server-pro/reference/session_user_settings.html>.

## Usage

``` r
use_rstudio_preferences(...)
```

## Arguments

- ...:

  \<[`dynamic-dots`](https://rlang.r-lib.org/reference/dyn-dots.html)\>
  Property-value pairs.

## Value

A named list of the previous values, invisibly.
