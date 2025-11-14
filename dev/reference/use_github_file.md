# Copy a file from any GitHub repo into the current project

Gets the content of a file from GitHub, from any repo the user can read,
and writes it into the active project. This function wraps an endpoint
of the GitHub API which supports specifying a target reference (i.e.
branch, tag, or commit) and which follows symlinks.

## Usage

``` r
use_github_file(
  repo_spec,
  path = NULL,
  save_as = NULL,
  ref = NULL,
  ignore = FALSE,
  open = FALSE,
  overwrite = FALSE,
  host = NULL
)
```

## Arguments

- repo_spec:

  A string identifying the GitHub repo or, alternatively, a GitHub file
  URL. Acceptable forms:

  - Plain `OWNER/REPO` spec

  - A blob URL, such as
    `"https://github.com/OWNER/REPO/blob/REF/path/to/some/file"`

  - A raw URL, such as
    `"https://raw.githubusercontent.com/OWNER/REPO/REF/path/to/some/file"`

  In the case of a URL, the `path`, `ref`, and `host` are extracted from
  it, in addition to the `repo_spec`.

- path:

  Path of file to copy, relative to the GitHub repo it lives in. This is
  extracted from `repo_spec` when user provides a URL.

- save_as:

  Path of file to create, relative to root of active project. Defaults
  to the last part of `path`, in the sense of `basename(path)` or
  `fs::path_file(path)`.

- ref:

  The name of a branch, tag, or commit. By default, the file at `path`
  will be copied from its current state in the repo's default branch.
  This is extracted from `repo_spec` when user provides a URL.

- ignore:

  Should the newly created file be added to `.Rbuildignore`?

- open:

  Open the newly created file for editing? Happens in RStudio, if
  applicable, or via
  [`utils::file.edit()`](https://rdrr.io/r/utils/file.edit.html)
  otherwise.

- overwrite:

  Force overwrite of existing file?

- host:

  GitHub host to target, passed to the `.api_url` argument of
  [`gh::gh()`](https://gh.r-lib.org/reference/gh.html). If unspecified,
  gh defaults to "https://api.github.com", although gh's default can be
  customised by setting the GITHUB_API_URL environment variable.

  For a hypothetical GitHub Enterprise instance, either
  "https://github.acme.com/api/v3" or "https://github.acme.com" is
  acceptable.

## Value

A logical indicator of whether a file was written, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
use_github_file(
  "https://github.com/r-lib/actions/blob/v2/examples/check-standard.yaml"
)

use_github_file(
  "r-lib/actions",
  path = "examples/check-standard.yaml",
  ref = "v2",
  save_as = ".github/workflows/R-CMD-check.yaml"
)
} # }
```
