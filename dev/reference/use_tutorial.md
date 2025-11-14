# Create a learnr tutorial

Creates a new tutorial below `inst/tutorials/`. Tutorials are
interactive R Markdown documents built with the [`learnr`
package](https://rstudio.github.io/learnr/index.html). `use_tutorial()`
does this setup:

- Adds learnr to Suggests in `DESCRIPTION`.

- Gitignores `inst/tutorials/*.html` so you don't accidentally track
  rendered tutorials.

- Creates a new `.Rmd` tutorial from a template and, optionally, opens
  it for editing.

- Adds new `.Rmd` to `.Rbuildignore`.

## Usage

``` r
use_tutorial(name, title, open = rlang::is_interactive())
```

## Arguments

- name:

  Base for file name to use for new `.Rmd` tutorial. Should consist only
  of numbers, letters, `_` and `-`. We recommend using lower case.

- title:

  The human-facing title of the tutorial.

- open:

  Open the newly created file for editing? Happens in RStudio, if
  applicable, or via
  [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
  otherwise.

## See also

The [learnr package
documentation](https://rstudio.github.io/learnr/index.html).

## Examples

``` r
if (FALSE) { # \dontrun{
use_tutorial("learn-to-do-stuff", "Learn to do stuff")
} # }
```
