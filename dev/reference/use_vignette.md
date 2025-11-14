# Create a vignette or article

Creates a new vignette or article in `vignettes/`. Articles are a
special type of vignette that appear on pkgdown websites, but are not
included in the package itself (because they are added to
`.Rbuildignore` automatically).

## Usage

``` r
use_vignette(name, title = NULL)

use_article(name, title = NULL)
```

## Arguments

- name:

  File name to use for new vignette. Should consist only of numbers,
  letters, `_` and `-`. Lower case is recommended. Can include the
  `".Rmd"` or `".qmd"` file extension, which also dictates whether to
  place an R Markdown or Quarto vignette. R Markdown (`".Rmd"`) is the
  current default, but it is anticipated that Quarto (`".qmd"`) will
  become the default in the future.

- title:

  The title of the vignette. If not provided, a title is generated from
  `name`.

## General setup

- Adds needed packages to `DESCRIPTION`.

- Adds `inst/doc` to `.gitignore` so built vignettes aren't tracked.

- Adds `vignettes/*.html` and `vignettes/*.R` to `.gitignore` so you
  never accidentally track rendered vignettes.

- For `*.qmd`, adds Quarto-related patterns to `.gitignore` and
  `.Rbuildignore`.

## See also

- The [vignettes chapter](https://r-pkgs.org/vignettes.html) of [R
  Packages](https://r-pkgs.org)

- The pkgdown vignette on Quarto:
  [`vignette("quarto", package = "pkgdown")`](https://pkgdown.r-lib.org/articles/quarto.html)

- The quarto (as in the R package) vignette on HTML vignettes:
  [`vignette("hello", package = "quarto")`](https://quarto-dev.github.io/quarto-r/articles/hello.html)

## Examples

``` r
if (FALSE) { # \dontrun{
use_vignette("how-to-do-stuff", "How to do stuff")
use_vignette("r-markdown-is-classic.Rmd", "R Markdown is classic")
use_vignette("quarto-is-cool.qmd", "Quarto is cool")
} # }
```
