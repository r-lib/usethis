# Utility functions for the active project

Most `use_*()` functions act on the **active project**. If it is unset,
usethis uses [rprojroot](https://rprojroot.r-lib.org) to find the
project root of the current working directory. It establishes the
project root by looking for signs such as:

- a `.here` file

- an RStudio Project, i.e. a `.Rproj` file

- an R package, i.e. a `DESCRIPTION` file

- a Git repository

- a Positron or VS Code workspace, i.e. a `.vscode/settings.json` file

- a Quarto project, i.e. a `_quarto.yml` file

- an renv project, i.e. a `renv.lock` file

usethis then stores the active project for use for the remainder of the
session.

In general, end user scripts should not contain direct calls to
`usethis::proj_*()` utility functions. They are internal functions that
are exported for occasional interactive use or use in packages that
extend usethis. End user code should call `here::here()` or other
functions from the [here](https://here.r-lib.org) or
[rprojroot](https://rprojroot.r-lib.org) packages to programmatically
detect a project and build paths within it.

If you are puzzled why a path (usually the current working directory)
does *not* appear to be inside project, it can be helpful to call
`here::dr_here()` to get much more verbose feedback.

## Usage

``` r
proj_get()

proj_set(path = ".", force = FALSE)

proj_path(..., ext = "")

with_project(
  path = ".",
  code,
  force = FALSE,
  setwd = TRUE,
  quiet = getOption("usethis.quiet", default = FALSE)
)

local_project(
  path = ".",
  force = FALSE,
  setwd = TRUE,
  quiet = getOption("usethis.quiet", default = FALSE),
  .local_envir = parent.frame()
)
```

## Arguments

- path:

  Path to set. This `path` should exist or be `NULL`.

- force:

  If `TRUE`, use this path without checking the usual criteria for a
  project. Use sparingly! The main application is to solve a temporary
  chicken-egg problem: you need to set the active project in order to
  add project-signalling infrastructure, such as initialising a Git repo
  or adding a `DESCRIPTION` file.

- ...:

  character vectors, if any values are NA, the result will also be NA.
  The paths follow the recycling rules used in the tibble package,
  namely that only length 1 arguments are recycled.

- ext:

  An optional extension to append to the generated path.

- code:

  Code to run with temporary active project

- setwd:

  Whether to also temporarily set the working directory to the active
  project, if it is not `NULL`

- quiet:

  Whether to suppress user-facing messages, while operating in the
  temporary active project

- .local_envir:

  The environment to use for scoping. Defaults to current execution
  environment.

## Functions

- `proj_get()`: Retrieves the active project and, if necessary, attempts
  to set it in the first place.

- `proj_set()`: Sets the active project.

- `proj_path()`: Builds paths within the active project returned by
  `proj_get()`. Thin wrapper around
  [`fs::path()`](https://fs.r-lib.org/reference/path.html).

- `with_project()`: Runs code with a temporary active project and,
  optionally, working directory. It is an example of the `with_*()`
  functions in [withr](https://withr.r-lib.org).

- `local_project()`: Sets an active project and, optionally, working
  directory until the current execution environment goes out of scope,
  e.g. the end of the current function or test. It is an example of the
  `local_*()` functions in [withr](https://withr.r-lib.org).

## See also

Other project functions:
[`proj_sitrep()`](https://usethis.r-lib.org/dev/reference/proj_sitrep.md)

## Examples

``` r
if (FALSE) { # \dontrun{
## see the active project
proj_get()

## manually set the active project
proj_set("path/to/target/project")

## build a path within the active project (both produce same result)
proj_path("R/foo.R")
proj_path("R", "foo", ext = "R")

## build a path within SOME OTHER project
with_project("path/to/some/other/project", proj_path("blah.R"))

## convince yourself that with_project() temporarily changes the project
with_project("path/to/some/other/project", print(proj_sitrep()))
} # }
```
