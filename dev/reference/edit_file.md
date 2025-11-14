# Open file for editing

Opens a file for editing in RStudio, if that is the active environment,
or via [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
otherwise. If the file does not exist, it is created. If the parent
directory does not exist, it is also created. `edit_template()`
specifically opens templates in `inst/templates` for use with
[`use_template()`](https://usethis.r-lib.org/dev/reference/use_template.md).

## Usage

``` r
edit_file(path, open = rlang::is_interactive())

edit_template(template = NULL, open = rlang::is_interactive())
```

## Arguments

- path:

  Path to target file.

- open:

  Whether to open the file for interactive editing.

- template:

  The target template file. If not specified, existing template files
  are offered for interactive selection.

## Value

Target path, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
edit_file("DESCRIPTION")
edit_file("~/.gitconfig")
} # }
```
