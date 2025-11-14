# Depend on another package

`use_package()` adds a CRAN package dependency to `DESCRIPTION` and
offers a little advice about how to best use it. `use_dev_package()`
adds a dependency on an in-development package, adding the dev repo to
`Remotes` so it will be automatically installed from the correct
location. There is no helper to remove a dependency: to do that, simply
remove that package from your `DESCRIPTION` file.

`use_package()` exists to support a couple of common maneuvers:

- Add a dependency to `Imports` or `Suggests` or `LinkingTo`.

- Add a minimum version to a dependency.

- Specify the minimum supported version for R.

`use_package()` probably works for slightly more exotic modifications,
but at some point, you should edit `DESCRIPTION` yourself by hand. There
is no intention to account for all possible edge cases.

## Usage

``` r
use_package(package, type = "Imports", min_version = NULL)

use_dev_package(package, type = "Imports", remote = NULL)
```

## Arguments

- package:

  Name of package to depend on.

- type:

  Type of dependency: must be one of "Imports", "Depends", "Suggests",
  "Enhances", or "LinkingTo" (or unique abbreviation). Matching is case
  insensitive.

- min_version:

  Optionally, supply a minimum version for the package. Set to `TRUE` to
  use the currently installed version or use a version string suitable
  for
  [`numeric_version()`](https://rdrr.io/r/base/numeric_version.html),
  such as "2.5.0".

- remote:

  By default, an `OWNER/REPO` GitHub remote is inserted. Optionally, you
  can supply a character string to specify the remote, e.g.
  `"gitlab::jimhester/covr"`, using any syntax supported by the [remotes
  package](https://remotes.r-lib.org/articles/dependencies.html#other-sources).

## See also

The [dependencies
section](https://r-pkgs.org/dependencies-mindset-background.html) of [R
Packages](https://r-pkgs.org).

## Examples

``` r
if (FALSE) { # \dontrun{
use_package("ggplot2")
use_package("dplyr", "suggests")
use_dev_package("glue")

# Depend on R version 4.1
use_package("R", type = "Depends", min_version = "4.1")
} # }
```
