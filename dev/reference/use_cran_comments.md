# CRAN submission comments

Creates `cran-comments.md`, a template for your communications with CRAN
when submitting a package. The goal is to clearly communicate the steps
you have taken to check your package on a wide range of operating
systems. If you are submitting an update to a package that is used by
other packages, you also need to summarize the results of your [reverse
dependency
checks](https://usethis.r-lib.org/dev/reference/use_revdep.md).

## Usage

``` r
use_cran_comments(open = rlang::is_interactive())
```

## Arguments

- open:

  Open the newly created file for editing? Happens in RStudio, if
  applicable, or via
  [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
  otherwise.
