# README badges

These helpers produce the markdown text you need in your README to
include badges that report information, such as the CRAN version or test
coverage, and link out to relevant external resources. To allow badges
to be added automatically, ensure your badge block starts with a line
containing only `<!-- badges: start -->` and ends with a line containing
only `<!-- badges: end -->`. The templates used by
[`use_readme_md()`](https://usethis.r-lib.org/dev/reference/use_readme_rmd.md)
and
[`use_readme_rmd()`](https://usethis.r-lib.org/dev/reference/use_readme_rmd.md)
include this block.

## Usage

``` r
use_badge(badge_name, href, src)

use_cran_badge()

use_bioc_badge()

use_lifecycle_badge(stage)

use_binder_badge(ref = git_default_branch(), urlpath = NULL)

use_r_universe_badge(repo_spec = NULL)

use_posit_cloud_badge(url)
```

## Arguments

- badge_name:

  Badge name. Used in error message and alt text

- href, src:

  Badge link and image src

- stage:

  Stage of the package lifecycle. One of "experimental", "stable",
  "superseded", or "deprecated".

- ref:

  A Git branch, tag, or SHA

- urlpath:

  An optional `urlpath` component to add to the link, e.g. `"rstudio"`
  to open an RStudio IDE instead of a Jupyter notebook. See the [binder
  documentation](https://mybinder.readthedocs.io/en/latest/howto/user_interface.html)
  for additional examples.

- repo_spec:

  Optional GitHub repo specification in this form: `owner/repo`. This
  can usually be inferred from the GitHub remotes of active project.

- url:

  A link to an existing [Posit Cloud](https://posit.cloud) project. See
  the [Posit Cloud
  documentation](https://posit.cloud/learn/guide#project-settings-access)
  for details on how to set project access and obtain a project link.

## Details

- `use_badge()`: a general helper used in all badge functions

- `use_bioc_badge()`: badge indicates [BioConductor build
  status](https://bioconductor.org/developers/)

- `use_cran_badge()`: badge indicates what version of your package is
  available on CRAN, powered by <https://www.r-pkg.org>

- `use_lifecycle_badge()`: badge declares the developmental stage of a
  package according to
  <https://lifecycle.r-lib.org/articles/stages.html>.

- `use_r_universe_badge()`: **\[experimental\]** badge indicates what
  version of your package is available on
  [R-universe](https://r-universe.dev/search) . It is assumed that you
  have already completed the [necessary R-universe
  setup](https://docs.r-universe.dev/publish/set-up.html).

- `use_binder_badge()`: badge indicates that your repository can be
  launched in an executable environment on <https://mybinder.org/>

- `use_posit_cloud_badge()`: badge indicates that your repository can be
  launched in a [Posit Cloud](https://posit.cloud) project

- `use_rscloud_badge()`: **\[deprecated\]** Use
  `use_posit_cloud_badge()` instead.

## See also

[`use_github_action()`](https://usethis.r-lib.org/dev/reference/use_github_action.md)
helps with the setup of various continuous integration workflows, some
of which will call these specialized badge helpers.

## Examples

``` r
if (FALSE) { # \dontrun{
use_cran_badge()
use_lifecycle_badge("stable")
} # }
```
