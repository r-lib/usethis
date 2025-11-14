# Set up a GitHub Actions workflow

Sets up continuous integration (CI) for an R package that is developed
on GitHub using [GitHub Actions](https://github.com/features/actions)
(GHA). CI can be used to trigger various operations for each push or
pull request, e.g. running `R CMD check` or building and deploying a
pkgdown site.

### Core workflows

There are three particularly important workflows that are used by many
packages:

- `check-standard`: Run `R CMD check` using R-latest on Linux, Mac, and
  Windows, and using R-devel and R-oldrel on Linux. This is a good
  baseline if you plan on submitting your package to CRAN.

- `test-coverage`: Compute test coverage and report to
  <https://about.codecov.io> by calling
  [`covr::codecov()`](http://covr.r-lib.org/reference/codecov.md).

- `pkgdown`: Automatically build and publish a pkgdown website. But we
  recommend instead calling
  [`use_pkgdown_github_pages()`](https://usethis.r-lib.org/dev/reference/use_pkgdown.md),
  which sets up the `pkgdown` workflow AND performs other important set
  up.

If you call `use_github_action()` without arguments, you'll get a choice
of some recommended workflows. Otherwise you can specify the name of any
workflow provided by `r-lib/actions`, which are listed at
<https://github.com/r-lib/actions/tree/v2/examples>. Finally you can
supply the full `url` to any workflow on GitHub.

### Other workflows

Other specific workflows are worth mentioning:

- `format-suggest` or `format-check` from
  [Air](https://posit-dev.github.io/air/): **\[experimental\]** Either
  of these workflows is a great way to keep your code well-formatted
  once you adopt Air in a project (possibly via
  [`use_air()`](https://usethis.r-lib.org/dev/reference/use_air.md)).
  Here's how to set them up:

      use_github_action(url = "https://github.com/posit-dev/setup-air/blob/main/examples/format-suggest.yaml")
      use_github_action(url = "https://github.com/posit-dev/setup-air/blob/main/examples/format-check.yaml")

  Learn more from [Air's documentation of its GHA
  integrations](https://posit-dev.github.io/air/integration-github-actions.html).

- `pr-commands`: **\[superseded\]** Enables the use of two R-specific
  commands in pull request issue comments: `/document` to run
  [`roxygen2::roxygenise()`](https://roxygen2.r-lib.org/reference/roxygenize.html)
  and `/style` to run `styler::style_pkg()`. Both will update the PR
  with any changes once they're done.

  We don't recommend new adoption of the `pr-commands` workflow. For
  code formatting, the Air workflows described above are preferred. We
  plan to re-implement documentation updates using a similar approach.

## Usage

``` r
use_github_action(
  name = NULL,
  ref = NULL,
  url = NULL,
  save_as = NULL,
  readme = NULL,
  ignore = TRUE,
  open = FALSE,
  badge = NULL
)
```

## Arguments

- name:

  Name of one of the example workflows from
  <https://github.com/r-lib/actions/tree/v2/examples> (with or without
  extension), e.g. `"pkgdown"`, `"check-standard.yaml"`.

  If the `name` starts with `check-`, `save_as` defaults to
  `R-CMD-check.yaml` and `badge` defaults to `TRUE`.

- ref:

  Desired Git reference, usually the name of a tag (`"v2"`) or branch
  (`"main"`). Other possibilities include a commit SHA (`"d1c516d"`) or
  `"HEAD"` (meaning "tip of remote's default branch"). If not specified,
  defaults to the latest published release of `r-lib/actions`
  (<https://github.com/r-lib/actions/releases>).

- url:

  The full URL to a `.yaml` file on GitHub. See more details in
  [`use_github_file()`](https://usethis.r-lib.org/dev/reference/use_github_file.md).

- save_as:

  Name of the local workflow file. Defaults to `name` or
  `fs::path_file(url)`. Do not specify any other part of the path; the
  parent directory will always be `.github/workflows`, within the active
  project.

- readme:

  The full URL to a `README` file that provides more details about the
  workflow. Ignored when `url` is `NULL`.

- ignore:

  Should the newly created file be added to `.Rbuildignore`?

- open:

  Open the newly created file for editing? Happens in RStudio, if
  applicable, or via
  [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
  otherwise.

- badge:

  Should we add a badge to the `README`?

## Examples

``` r
if (FALSE) { # \dontrun{
use_github_action()

use_github_action("check-standard")

use_github_action("pkgdown")

use_github_action(
  url = "https://github.com/posit-dev/setup-air/blob/main/examples/format-suggest.yaml"
)
} # }
```
