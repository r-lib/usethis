# Use roxygen2 with markdown

If you are already using roxygen2, but not with markdown, you'll need to
use [roxygen2md](https://roxygen2md.r-lib.org) to convert existing Rd
expressions to markdown. The conversion is not perfect, so make sure to
check the results.

## Usage

``` r
use_roxygen_md(overwrite = FALSE)
```

## Arguments

- overwrite:

  Whether to overwrite an existing `Roxygen` field in `DESCRIPTION` with
  `"list(markdown = TRUE)"`.
