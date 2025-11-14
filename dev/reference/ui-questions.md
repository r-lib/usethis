# User interface - Questions

**\[superseded\]**

`ui_yeah()` and `ui_nope()` are technically superseded, but, unlike the
rest of the legacy
[`ui_*()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
functions, there's not yet a drop-in replacement available in the [cli
package](https://cli.r-lib.org/). `ui_yeah()` and `ui_nope()` are no
longer used internally in usethis.

## Usage

``` r
ui_yeah(
  x,
  yes = c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely"),
  no = c("No way", "Not now", "Negative", "No", "Nope", "Absolutely not"),
  n_yes = 1,
  n_no = 2,
  shuffle = TRUE,
  .envir = parent.frame()
)

ui_nope(
  x,
  yes = c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely"),
  no = c("No way", "Not now", "Negative", "No", "Nope", "Absolutely not"),
  n_yes = 1,
  n_no = 2,
  shuffle = TRUE,
  .envir = parent.frame()
)
```

## Arguments

- x:

  A character vector.

  For block styles, conditions, and questions, each element of the
  vector becomes a line, and the result is processed by
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html). For
  inline styles, each element of the vector becomes an entry in a comma
  separated list.

- yes:

  A character vector of "yes" strings, which are randomly sampled to
  populate the menu.

- no:

  A character vector of "no" strings, which are randomly sampled to
  populate the menu.

- n_yes:

  An integer. The number of "yes" strings to include.

- n_no:

  An integer. The number of "no" strings to include.

- shuffle:

  A logical. Should the order of the menu options be randomly shuffled?

- .envir:

  Used to ensure that
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) gets
  the correct environment. For expert use only.

## Value

A logical. `ui_yeah()` returns `TRUE` when the user selects a "yes"
option and `FALSE` otherwise, i.e. when user selects a "no" option or
refuses to make a selection (cancels). `ui_nope()` is the logical
opposite of `ui_yeah()`.

## Examples

``` r
if (FALSE) { # \dontrun{
ui_yeah("Do you like R?")
ui_nope("Have you tried turning it off and on again?", n_yes = 1, n_no = 1)
ui_yeah("Are you sure its plugged in?", yes = "Yes", no = "No", shuffle = FALSE)
} # }
```
