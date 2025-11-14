# Create an upkeep checklist in a GitHub issue

This opens an issue in your package repository with a checklist of tasks
for regular maintenance of your package. This is a fairly opinionated
list of tasks but we believe taking care of them will generally make
your package better, easier to maintain, and more enjoyable for your
users. Some of the tasks are meant to be performed only once (and once
completed shouldn't show up in subsequent lists), and some should be
reviewed periodically. The tidyverse team uses a similar function
[`use_tidy_upkeep_issue()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
for our annual package Spring Cleaning.

## Usage

``` r
use_upkeep_issue(year = NULL)
```

## Arguments

- year:

  Year you are performing the upkeep, used in the issue title. Defaults
  to current year

## Examples

``` r
if (FALSE) { # \dontrun{
use_upkeep_issue()
} # }
```
