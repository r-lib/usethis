# Reverse dependency checks

Performs set up for checking the reverse dependencies of an R package,
as implemented by the revdepcheck package:

- Creates `revdep/` directory and adds it to `.Rbuildignore`

- Populates `revdep/.gitignore` to prevent tracking of various revdep
  artefacts

- Prompts user to run the checks with `revdepcheck::revdep_check()`

## Usage

``` r
use_revdep()
```
