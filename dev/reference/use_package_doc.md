# Package-level documentation

Adds a dummy `.R` file that will cause roxygen2 to generate basic
package-level documentation. If your package is named "foo", this will
make help available to the user via `?foo` or `package?foo`. Once you
call `devtools::document()`, roxygen2 will flesh out the `.Rd` file
using data from the `DESCRIPTION`. That ensures you don't need to repeat
(and remember to update!) the same information in multiple places. This
`.R` file is also a good place for roxygen directives that apply to the
whole package (vs. a specific function), such as global namespace tags
like `@importFrom`.

## Usage

``` r
use_package_doc(open = rlang::is_interactive())
```

## Arguments

- open:

  Open the newly created file for editing? Happens in RStudio, if
  applicable, or via
  [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
  otherwise.

## See also

The [documentation chapter](https://r-pkgs.org/man.html) of [R
Packages](https://r-pkgs.org)
