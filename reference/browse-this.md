# Visit important project-related web pages

These functions take you to various web pages associated with a project
(often, an R package) and return the target URL(s) invisibly. To form
these URLs we consult:

- Git remotes configured for the active project that appear to be hosted
  on a GitHub deployment

- DESCRIPTION file for the active project or the specified `package`.
  The DESCRIPTION file is sought first in the local package library and
  then on CRAN.

- Fixed templates:

  - Circle CI: `https://circleci.com/gh/{OWNER}/{PACKAGE}`

  - CRAN landing page: `https://cran.r-project.org/package={PACKAGE}`

  - GitHub mirror of a CRAN package: `https://github.com/cran/{PACKAGE}`
    Templated URLs aren't checked for existence, so there is no
    guarantee there will be content at the destination.

## Usage

``` r
browse_package(package = NULL)

browse_project()

browse_github(package = NULL)

browse_github_issues(package = NULL, number = NULL)

browse_github_pulls(package = NULL, number = NULL)

browse_github_actions(package = NULL)

browse_circleci(package = NULL)

browse_cran(package = NULL)
```

## Arguments

- package:

  Name of package. If `NULL`, the active project is targeted, regardless
  of whether it's an R package or not.

- number:

  Optional, to specify an individual GitHub issue or pull request. Can
  be a number or `"new"`.

## Details

- `browse_package()`: Assembles a list of URLs and lets user choose one
  to visit in a web browser. In a non-interactive session, returns all
  discovered URLs.

- `browse_project()`: Thin wrapper around `browse_package()` that always
  targets the active usethis project.

- `browse_github()`: Visits a GitHub repository associated with the
  project. In the case of a fork, you might be asked to specify if
  you're interested in the source repo or your fork.

- `browse_github_issues()`: Visits the GitHub Issues index or one
  specific issue.

- `browse_github_pulls()`: Visits the GitHub Pull Request index or one
  specific pull request.

- `browse_circleci()`: Visits the project's page on [Circle
  CI](https://circleci.com).

- `browse_cran()`: Visits the package on CRAN, via the canonical URL.

## Examples

``` r
# works on the active project
# browse_project()

browse_package("httr")
browse_github("gh")
#> ☐ Open URL <https://github.com/r-lib/gh>.
browse_github_issues("fs")
#> ☐ Open URL <https://github.com/r-lib/fs/issues/>.
browse_github_issues("fs", 1)
#> ☐ Open URL <https://github.com/r-lib/fs/issues/1>.
browse_github_pulls("curl")
#> ☐ Open URL <https://github.com/jeroen/curl/pulls/>.
browse_github_pulls("curl", 183)
#> ☐ Open URL <https://github.com/jeroen/curl/pull/183>.
browse_cran("MASS")
#> ☐ Open URL <https://cran.r-project.org/package=MASS>.
```
