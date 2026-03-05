# Create README files

Creates skeleton README files with possible stubs for

- a high-level description of the project/package and its goals

- R code to install from GitHub, if GitHub usage detected

- a basic example

Use `qmd` or `Rmd` if you want a rich intermingling of code and output.
Use `md` for a basic README. `README.qmd` and `README.Rmd` will be
automatically added to `.Rbuildignore`. The resulting README is
populated with default YAML frontmatter and R fenced code blocks (`md`)
or chunks (`qmd`, `Rmd`).

If you use `qmd` or `Rmd`, you'll still need to render it regularly, to
keep `README.md` up-to-date. `devtools::build_readme()` is handy for
this. You could also use GitHub Actions to re-render `README.qmd` or
`README.Rmd` every time you push. An example workflow can be found in
the `examples/` directory here: <https://github.com/r-lib/actions/>.

If the current project is a Git repo, then `use_readme_qmd()` and
`use_readme_rmd()` automatically configure a pre-commit hook that helps
keep `README.md` synchronized with the source file. The hook creates
friction if you try to commit when `README.qmd` or `README.Rmd` has been
edited more recently than `README.md`. If this hook causes more problems
than it solves for you, it is implemented in `.git/hooks/pre-commit`,
which you can modify or even delete.

## Usage

``` r
use_readme_rmd(open = rlang::is_interactive())

use_readme_qmd(open = rlang::is_interactive())

use_readme_md(open = rlang::is_interactive())
```

## Arguments

- open:

  Open the newly created file for editing? Happens in RStudio, if
  applicable, or via
  [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
  otherwise.

## See also

The [other markdown files
section](https://r-pkgs.org/other-markdown.html) of [R
Packages](https://r-pkgs.org).

## Examples

``` r
if (FALSE) { # \dontrun{
use_readme_qmd()
use_readme_rmd()
use_readme_md()
} # }
```
