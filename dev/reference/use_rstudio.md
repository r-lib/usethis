# Add RStudio Project infrastructure

It is likely that you want to use
[`create_project()`](https://usethis.r-lib.org/dev/reference/create_package.md)
or
[`create_package()`](https://usethis.r-lib.org/dev/reference/create_package.md)
instead of `use_rstudio()`! Both `create_*()` functions can add RStudio
Project infrastructure to a pre-existing project or package.
`use_rstudio()` is mostly for internal use or for those creating a
usethis-like package for their organization. It does the following in
the current project, often after executing
`proj_set(..., force = TRUE)`:

- Creates an `.Rproj` file

- Adds RStudio files to `.gitignore`

- Adds RStudio files to `.Rbuildignore`, if project is a package

## Usage

``` r
use_rstudio(line_ending = c("posix", "windows"), reformat = TRUE)
```

## Arguments

- line_ending:

  Line ending

- reformat:

  If `TRUE`, the `.Rproj` is setup with common options that reformat
  files on save: adding a trailing newline, trimming trailing
  whitespace, and setting the line-ending. This is best practice for new
  projects.

  If `FALSE`, these options are left unset, which is more appropriate
  when you're contributing to someone else's project that does not have
  its own `.Rproj` file.
