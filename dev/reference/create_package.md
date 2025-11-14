# Create a package or project

These functions create an R project:

- `create_package()` creates an R package.

- `create_project()` creates a non-package project, i.e. a data analysis
  project.

- **\[experimental\]** `create_quarto_project()` creates a Quarto
  project. It is a simplified convenience wrapper around
  [`quarto::quarto_create_project()`](https://quarto-dev.github.io/quarto-r/reference/quarto_create_project.html),
  which you should call directly for more advanced usage.

These functions work best when creating a project *de novo*, but
`create_package()` and `create_project()` can be called on an existing
project; you will be asked before any existing files are changed.

## Usage

``` r
create_package(
  path,
  fields = list(),
  rstudio = rstudioapi::isAvailable(),
  roxygen = TRUE,
  check_name = TRUE,
  open = rlang::is_interactive()
)

create_project(
  path,
  rstudio = rstudioapi::isAvailable(),
  open = rlang::is_interactive()
)

create_quarto_project(
  path,
  type = "default",
  rstudio = rstudioapi::isAvailable(),
  open = rlang::is_interactive()
)
```

## Arguments

- path:

  A path. If it exists, it is used. If it does not exist, it is created,
  provided that the parent path exists.

- fields:

  A named list of fields to add to `DESCRIPTION`, potentially overriding
  default values. See
  [`use_description()`](https://usethis.r-lib.org/dev/reference/use_description.md)
  for how you can set personalized defaults using package options.

- rstudio:

  If `TRUE`, calls
  [`use_rstudio()`](https://usethis.r-lib.org/dev/reference/use_rstudio.md)
  to make the new package or project into an [RStudio
  Project](https://r-pkgs.org/workflow101.html#sec-workflow101-rstudio-projects).

  If `FALSE`, the goal is to ensure that the directory can be recognized
  as a project by, for example, the [here](https://here.r-lib.org)
  package. If the project is neither an R package nor a Quarto project,
  a sentinel `.here` file is placed to mark the project root.

- roxygen:

  Do you plan to use roxygen2 to document your package?

- check_name:

  Whether to check if the name is valid for CRAN and throw an error if
  not.

- open:

  If `TRUE`,
  [activates](https://usethis.r-lib.org/dev/reference/proj_activate.md)
  the new project:

  - If using RStudio or Positron, the new project is opened in a new
    session, window, or browser tab, depending on the product (RStudio
    or Positron) and context (desktop or server).

  - Otherwise, the working directory and active project of the current R
    session are changed to the new project.

- type:

  The type of Quarto project to create. See
  [`?quarto::quarto_create_project`](https://quarto-dev.github.io/quarto-r/reference/quarto_create_project.html)
  for the most up-to-date list, but `"website"`, `"blog"`, `"book"`, and
  `"manuscript"` are common choices.

## Value

Path to the newly created project or package, invisibly.

## See also

[`create_tidy_package()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
is a convenience function that extends `create_package()` by immediately
applying as many of the tidyverse development conventions as possible.
