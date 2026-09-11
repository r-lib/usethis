# Use "latest" versions of all dependencies

Pins minimum versions of all `Imports` and `Depends` dependencies to
latest ones (as determined by `source`). Useful for the tidyverse
package, but should otherwise be used with extreme care.

## Usage

``` r
use_latest_dependencies(overwrite = TRUE, source = c("CRAN", "local"))
```

## Arguments

- overwrite:

  By default (`TRUE`), all dependencies will be modified. Set to `FALSE`
  to only modify dependencies without version specifications.

- source:

  Use "CRAN" or "local" package versions.
