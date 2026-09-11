# Use GitHub links in URL and BugReports

Populates the `URL` and `BugReports` fields of a GitHub-using R package
with appropriate links. The GitHub repo to link to is determined from
the current project's GitHub remotes:

- If we are not working with a fork, this function expects `origin` to
  be a GitHub remote and the links target that repo.

- If we are working in a fork, this function expects to find two GitHub
  remotes: `origin` (the fork) and `upstream` (the fork's parent)
  remote. In an interactive session, the user can confirm which repo to
  use for the links. In a noninteractive session, links are formed using
  `upstream`.

## Usage

``` r
use_github_links(overwrite = FALSE)
```

## Arguments

- overwrite:

  By default, `use_github_links()` will not overwrite existing fields.
  Set to `TRUE` to overwrite existing links.

## Examples

``` r
if (FALSE) { # \dontrun{
use_github_links()
} # }
```
