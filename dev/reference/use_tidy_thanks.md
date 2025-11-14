# Identify contributors via GitHub activity

Derives a list of GitHub usernames, based on who has opened issues or
pull requests. Used to populate the acknowledgment section of package
release blog posts at <https://www.tidyverse.org/blog/>. If no arguments
are given, we retrieve all contributors to the active project since its
last (GitHub) release. Unexported helper functions, `releases()` and
`ref_df()` can be useful interactively to get a quick look at release
tag names and a data frame about refs (defaulting to releases),
respectively.

## Usage

``` r
use_tidy_thanks(repo_spec = NULL, from = NULL, to = NULL)
```

## Arguments

- repo_spec:

  Optional GitHub repo specification in any form accepted for the
  `repo_spec` argument of
  [`create_from_github()`](https://usethis.r-lib.org/dev/reference/create_from_github.md)
  (plain spec or a browser or Git URL). A URL specification is the only
  way to target a GitHub host other than `"github.com"`, which is the
  default.

- from, to:

  GitHub ref (i.e., a SHA, tag, or release) or a timestamp in ISO 8601
  format, specifying the start or end of the interval of interest, in
  the sense of `[from, to]`. Examples: "08a560d", "v1.3.0",
  "2018-02-24T00:13:45Z", "2018-05-01". When `from = NULL, to = NULL`,
  we set `from` to the timestamp of the most recent (GitHub) release.
  Otherwise, `NULL` means "no bound".

## Value

A character vector of GitHub usernames, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
# active project, interval = since the last release
use_tidy_thanks()

# active project, interval = since a specific datetime
use_tidy_thanks(from = "2020-07-24T00:13:45Z")

# r-lib/usethis, interval = since a certain date
use_tidy_thanks("r-lib/usethis", from = "2020-08-01")

# r-lib/usethis, up to a specific release
use_tidy_thanks("r-lib/usethis", from = NULL, to = "v1.1.0")

# r-lib/usethis, since a specific commit, up to a specific date
use_tidy_thanks("r-lib/usethis", from = "08a560d", to = "2018-05-14")

# r-lib/usethis, but with copy/paste of a browser URL
use_tidy_thanks("https://github.com/r-lib/usethis")
} # }
```
