# Increment package version

usethis supports semantic versioning, which is described in more detail
in the [version
section](https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number)
of [R Packages](https://r-pkgs.org). A version number breaks down like
so:

    <major>.<minor>.<patch>       (released version)
    <major>.<minor>.<patch>.<dev> (dev version)

`use_version()` increments the "Version" field in `DESCRIPTION`, adds a
new heading to `NEWS.md` (if it exists), commits those changes (if
package uses Git), and optionally pushes (if safe to do so). It makes
the same update to a line like `PKG_version = "x.y.z";` in
`src/version.c` (if it exists).

`use_dev_version()` increments to a development version, e.g. from 1.0.0
to 1.0.0.9000. If the existing version is already a development version
with four components, it does nothing. Thin wrapper around
`use_version()`.

## Usage

``` r
use_version(which = NULL, push = FALSE)

use_dev_version(push = FALSE)
```

## Arguments

- which:

  A string specifying which level to increment, one of: "major",
  "minor", "patch", "dev". If `NULL`, user can choose interactively.

- push:

  If `TRUE`, also attempts to push the commits to the remote branch.

## See also

The [version
section](https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number)
of [R Packages](https://r-pkgs.org).

## Examples

``` r
if (FALSE) { # \dontrun{
## for interactive selection, do this:
use_version()

## request a specific type of increment
use_version("minor")
use_dev_version()
} # }
```
