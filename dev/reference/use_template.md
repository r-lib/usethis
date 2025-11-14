# Use a usethis-style template

Creates a file from data and a template found in a package. Provides
control over file name, the addition to `.Rbuildignore`, and opening the
file for inspection.

## Usage

``` r
use_template(
  template,
  save_as = template,
  data = list(),
  ignore = FALSE,
  open = FALSE,
  package = "usethis"
)
```

## Arguments

- template:

  Path to template file relative to `templates/` directory within
  `package`; see details.

- save_as:

  Path of file to create, relative to root of active project. Defaults
  to `template`

- data:

  A list of data passed to the template.

- ignore:

  Should the newly created file be added to `.Rbuildignore`?

- open:

  Open the newly created file for editing? Happens in RStudio, if
  applicable, or via
  [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
  otherwise.

- package:

  Name of the package where the template is found.

## Value

A logical vector indicating if file was modified.

## Details

This function can be used as the engine for a templating function in
other packages. The `template` argument is used along with the `package`
argument to derive the path to your template file; it will be expected
at `fs::path_package(package = package, "templates", template)`. We use
[`fs::path_package()`](https://fs.r-lib.org/reference/path_package.html)
instead of
[`base::system.file()`](https://rdrr.io/r/base/system.file.html) so that
path construction works even in a development workflow, e.g., works with
`devtools::load_all()` or
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html).
*Note this describes the behaviour of
[`fs::path_package()`](https://fs.r-lib.org/reference/path_package.html)
in fs v1.2.7.9001 and higher.*

To interpolate your data into the template, supply a list using the
`data` argument. Internally, this function uses
[`whisker::whisker.render()`](https://rdrr.io/pkg/whisker/man/whisker.render.html)
to combine your template file with your data.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Note: running this will write `NEWS.md` to your working directory
  use_template(
    template = "NEWS.md",
    data = list(Package = "acme", Version = "1.2.3"),
    package = "usethis"
  )
} # }
```
