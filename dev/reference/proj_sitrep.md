# Report working directory and usethis/RStudio project

`proj_sitrep()` reports

- current working directory

- the active usethis project

- the active RStudio Project

Call this function if things seem weird and you're not sure what's wrong
or how to fix it. Usually, all three of these should coincide (or be
unset) and `proj_sitrep()` provides suggested commands for getting back
to this happy state.

## Usage

``` r
proj_sitrep()
```

## Value

A named list, with S3 class `sitrep` (for printing purposes), reporting
current working directory, active usethis project, and active RStudio
Project

## See also

Other project functions:
[`proj_utils`](https://usethis.r-lib.org/dev/reference/proj_utils.md)

## Examples

``` r
proj_sitrep()
#> •  working_directory:
#>   "/home/runner/work/usethis/usethis/docs/dev/reference"
#> • active_usethis_proj: <unset>
#> • active_rstudio_proj: <unset>
#> ℹ There is currently no active usethis project.
#> ℹ usethis attempts to activate a project upon first need.
#> ☐ Call `usethis::proj_get()` to initiate project discovery.
#> ☐ Call `proj_set("path/to/project")` or
#>   `proj_activate("path/to/project")` to provide an explicit path.
```
