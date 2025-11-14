# Helpers for tidyverse development

These helpers follow tidyverse conventions which are generally a little
stricter than the defaults, reflecting the need for greater rigor in
commonly used packages.

## Usage

``` r
use_tidy_github_actions(ref = NULL)

create_tidy_package(path, copyright_holder = NULL)

use_tidy_description()

use_tidy_dependencies()

use_tidy_contributing()

use_tidy_support()

use_tidy_issue_template()

use_tidy_coc()

use_tidy_github()

use_tidy_logo(geometry = "240x278", retina = TRUE)

use_tidy_upkeep_issue(last_upkeep = last_upkeep_year())
```

## Arguments

- ref:

  Desired Git reference, usually the name of a tag (`"v2"`) or branch
  (`"main"`). Other possibilities include a commit SHA (`"d1c516d"`) or
  `"HEAD"` (meaning "tip of remote's default branch"). If not specified,
  defaults to the latest published release of `r-lib/actions`
  (<https://github.com/r-lib/actions/releases>).

- path:

  A path. If it exists, it is used. If it does not exist, it is created,
  provided that the parent path exists.

- copyright_holder:

  Name of the copyright holder or holders. This defaults to
  `"{package name} authors"`; you should only change this if you use a
  CLA to assign copyright to a single entity.

- geometry:

  a
  [magick::geometry](https://docs.ropensci.org/magick/reference/geometry.html)
  string specifying size. The default assumes that you have a hex logo
  using spec from
  [http://hexb.in/sticker.html](http://hexb.in/sticker.md).

- retina:

  `TRUE`, the default, scales the image on the README, assuming that
  geometry is double the desired size.

- last_upkeep:

  Year of last upkeep. By default, the `Config/usethis/last-upkeep`
  field in `DESCRIPTION` is consulted for this, if it's defined. If
  there's no information on the last upkeep, the issue will contain the
  full checklist.

## Details

- `use_tidy_github_actions()`: Sets up the following workflows using
  [GitHub Actions](https://github.com/features/actions):

  - Run `R CMD check` on the current release, devel, and four previous
    versions of R. The build matrix also ensures `R CMD check` is run at
    least once on each of the three major operating systems (Linux,
    macOS, and Windows).

  - Report test coverage.

  - Build and deploy a pkgdown site.

  - Check the formatting of incoming pull requests with Air and suggest
    fixes as necessary.

    This is how the tidyverse team checks its packages, but it is
    overkill for less widely used packages. For `R CMD check`, consider
    using the more streamlined workflow set up by
    [`use_github_action("check-standard")`](https://usethis.r-lib.org/dev/reference/use_github_action.md).

&nbsp;

- `create_tidy_package()`: creates a new package, immediately applies as
  many of the tidyverse conventions as possible, issues a few reminders,
  and activates the new package.

- `use_tidy_dependencies()`: sets up standard dependencies used by all
  tidyverse packages (except packages that are designed to be dependency
  free).

- `use_tidy_description()`: puts fields in standard order and
  alphabetises dependencies.

- `use_tidy_eval()`: imports a standard set of helpers to facilitate
  programming with the tidy eval toolkit.

- [`use_tidy_style()`](https://usethis.r-lib.org/dev/reference/tidy-deprecated.md):
  styles source code according to the [tidyverse style
  guide](https://style.tidyverse.org). This function will overwrite
  files! See below for usage advice.

- `use_tidy_contributing()`: adds standard tidyverse contributing
  guidelines.

- `use_tidy_issue_template()`: adds a standard tidyverse issue template.

- `use_tidy_release_test_env()`: updates the test environment section in
  `cran-comments.md`.

- `use_tidy_support()`: adds a standard description of support resources
  for the tidyverse.

- `use_tidy_coc()`: equivalent to
  [`use_code_of_conduct()`](https://usethis.r-lib.org/dev/reference/use_code_of_conduct.md),
  but puts the document in a `.github/` subdirectory.

- `use_tidy_github()`: convenience wrapper that calls
  `use_tidy_contributing()`, `use_tidy_issue_template()`,
  `use_tidy_support()`, `use_tidy_coc()`.

- [`use_tidy_github_labels()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  calls
  [`use_github_labels()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  to implement tidyverse conventions around GitHub issue label names and
  colours.

- `use_tidy_upkeep_issue()` creates an issue containing a checklist of
  actions to bring your package up to current tidyverse standards. Also
  records the current date in the `Config/usethis/last-upkeep` field in
  `DESCRIPTION`.

- `use_tidy_logo()` calls
  [`use_logo()`](https://usethis.r-lib.org/dev/reference/use_logo.md) on
  the appropriate hex sticker PNG file at
  <https://github.com/rstudio/hex-stickers>.
