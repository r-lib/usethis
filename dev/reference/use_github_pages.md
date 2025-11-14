# Configure a GitHub Pages site

Activates or reconfigures a GitHub Pages site for a project hosted on
GitHub. This function anticipates two specific usage modes:

- Publish from the root directory of a `gh-pages` branch, which is
  assumed to be only (or at least primarily) a remote branch. Typically
  the `gh-pages` branch is managed by an automatic "build and deploy"
  job, such as the one configured by
  [`use_github_action("pkgdown")`](https://usethis.r-lib.org/dev/reference/use_github_action.md).

- Publish from the `"/docs"` directory of a "regular" branch, probably
  the repo's default branch. The user is assumed to have a plan for how
  they will manage the content below `"/docs"`.

## Usage

``` r
use_github_pages(branch = "gh-pages", path = "/", cname = NA)
```

## Arguments

- branch, path:

  Branch and path for the site source. The default of
  `branch = "gh-pages"` and `path = "/"` reflects strong GitHub support
  for this configuration: when a `gh-pages` branch is first created, it
  is *automatically* published to Pages, using the source found in
  `"/"`. If a `gh-pages` branch does not yet exist on the host,
  `use_github_pages()` creates an empty, orphan remote branch.

  The most common alternative is to use the repo's default branch,
  coupled with `path = "/docs"`. It is the user's responsibility to
  ensure that this `branch` pre-exists on the host.

  Note that GitHub does not support an arbitrary `path` and, at the time
  of writing, only `"/"` or `"/docs"` are accepted.

- cname:

  Optional, custom domain name. The `NA` default means "don't set or
  change this", whereas a value of `NULL` removes any previously
  configured custom domain.

  Note that this *can* add or modify a CNAME file in your repository. If
  you are using Pages to host a pkgdown site, it is better to specify
  its URL in the pkgdown config file and let pkgdown manage CNAME.

## Value

Site metadata returned by the GitHub API, invisibly

## See also

- [`use_pkgdown_github_pages()`](https://usethis.r-lib.org/dev/reference/use_pkgdown.md)
  combines `use_github_pages()` with other functions to fully configure
  a pkgdown site

- <https://docs.github.com/en/pages>

- <https://docs.github.com/en/rest/pages>

## Examples

``` r
if (FALSE) { # \dontrun{
use_github_pages()
use_github_pages(branch = git_default_branch(), path = "/docs")
} # }
```
