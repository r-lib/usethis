# Create or modify a DESCRIPTION file

`use_description()` creates a `DESCRIPTION` file. Although mostly
associated with R packages, a `DESCRIPTION` file can also be used to
declare dependencies for a non-package project. Within such a project,
`devtools::install_deps()` can then be used to install all the required
packages. Note that, by default, `use_decription()` checks for a
CRAN-compliant package name. You can turn this off with
`check_name = FALSE`.

usethis consults the following sources, in this order, to set
`DESCRIPTION` fields:

- `fields` argument of
  [`create_package()`](https://usethis.r-lib.org/dev/reference/create_package.md)
  or `use_description()`

- `getOption("usethis.description")`

- Defaults built into usethis

The fields discovered via options or the usethis package can be viewed
with `use_description_defaults()`.

If you create a lot of packages, consider storing personalized defaults
as a named list in an option named `"usethis.description"`. Here's an
example of code to include in `.Rprofile`, which can be opened via
[`edit_r_profile()`](https://usethis.r-lib.org/dev/reference/edit.md):

    options(
      usethis.description = list(
        "Authors@R" = utils::person(
          "Jane", "Doe",
          email = "jane@example.com",
          role = c("aut", "cre"),
          comment = c(ORCID = "YOUR-ORCID-ID")
        ),
        Language =  "es",
        License = "MIT + file LICENSE"
      )
    )

Prior to usethis v2.0.0, `getOption("devtools.desc")` was consulted for
backwards compatibility, but now only the `"usethis.description"` option
is supported.

## Usage

``` r
use_description(fields = list(), check_name = TRUE, roxygen = TRUE)

use_description_defaults(package = NULL, roxygen = TRUE, fields = list())
```

## Arguments

- fields:

  A named list of fields to add to `DESCRIPTION`, potentially overriding
  default values. Default values are taken from the
  `"usethis.description"` option or the usethis package (in that order),
  and can be viewed with `use_description_defaults()`.

- check_name:

  Whether to check if the name is valid for CRAN and throw an error if
  not.

- roxygen:

  If `TRUE`, sets `RoxygenNote` to current roxygen2 version

- package:

  Package name

## See also

The [description chapter](https://r-pkgs.org/description.html) of [R
Packages](https://r-pkgs.org)

## Examples

``` r
if (FALSE) { # \dontrun{
use_description()

use_description(fields = list(Language = "es"))

use_description_defaults()
} # }
```
