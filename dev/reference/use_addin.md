# Add minimal RStudio Addin binding

This function helps you add a minimal [RStudio
Addin](https://rstudio.github.io/rstudioaddins/) binding to
`inst/rstudio/addins.dcf`.

## Usage

``` r
use_addin(addin = "new_addin", open = rlang::is_interactive())
```

## Arguments

- addin:

  Name of the addin function, which should be defined in the `R` folder.

- open:

  Open the newly created file for editing? Happens in RStudio, if
  applicable, or via
  [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
  otherwise.
