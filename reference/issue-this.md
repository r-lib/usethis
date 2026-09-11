# Helpers for GitHub issues

The `issue_*` family of functions allows you to perform common
operations on GitHub issues from within R. They're designed to help you
efficiently deal with large numbers of issues, particularly motivated by
the challenges faced by the tidyverse team.

- `issue_close_community()` closes an issue, because it's not a bug
  report or feature request, and points the author towards Posit
  Community as a better place to discuss usage
  (<https://forum.posit.co>).

- `issue_reprex_needed()` labels the issue with the "reprex" label and
  gives the author some advice about what is needed.

## Usage

``` r
issue_close_community(number, reprex = FALSE)

issue_reprex_needed(number)
```

## Arguments

- number:

  Issue number

- reprex:

  Does the issue also need a reprex?

## Saved replies

Unlike GitHub's "saved replies", these functions can:

- Be shared between people

- Perform other actions, like labelling, or closing

- Have additional arguments

- Include randomness (like friendly gifs)

## Examples

``` r
if (FALSE) { # \dontrun{
issue_close_community(12, reprex = TRUE)

issue_reprex_needed(241)
} # }
```
