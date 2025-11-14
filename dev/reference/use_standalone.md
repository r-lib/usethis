# Use a standalone file from another repo

A "standalone" file implements a minimum set of functionality in such a
way that it can be copied into another package. `use_standalone()` makes
it easy to get such a file into your own repo.

It always overwrites an existing standalone file of the same name,
making it easy to update previously imported code.

## Usage

``` r
use_standalone(repo_spec, file = NULL, ref = NULL, host = NULL)
```

## Arguments

- repo_spec:

  A string identifying the GitHub repo in one of these forms:

  - Plain `OWNER/REPO` spec

  - Browser URL, such as `"https://github.com/OWNER/REPO"`

  - HTTPS Git URL, such as `"https://github.com/OWNER/REPO.git"`

  - SSH Git URL, such as `"git@github.com:OWNER/REPO.git"`

- file:

  Name of standalone file. The `standalone-` prefix and file extension
  are optional. If omitted, will allow you to choose from the standalone
  files offered by that repo.

- ref:

  The name of a branch, tag, or commit. By default, the file at `path`
  will be copied from its current state in the repo's default branch.
  This is extracted from `repo_spec` when user provides a URL.

- host:

  GitHub host to target, passed to the `.api_url` argument of
  [`gh::gh()`](https://gh.r-lib.org/reference/gh.html). If `repo_spec`
  is a URL, `host` is extracted from that.

  If unspecified, gh defaults to "https://api.github.com", although gh's
  default can be customised by setting the GITHUB_API_URL environment
  variable.

  For a hypothetical GitHub Enterprise instance, either
  "https://github.acme.com/api/v3" or "https://github.acme.com" is
  acceptable.

## Supported fields

A standalone file has YAML frontmatter that provides additional
information, such as where the file originates from and when it was last
updated. Here is an example:

    ---
    repo: r-lib/rlang
    file: standalone-types-check.R
    last-updated: 2023-03-07
    license: https://unlicense.org
    dependencies: standalone-obj-type.R
    imports: rlang (>= 1.1.0)
    ---

Two of these fields are consulted by `use_standalone()`:

- `dependencies`: A file or a list of files in the same repo that the
  standalone file depends on. These files are retrieved automatically by
  `use_standalone()`.

- `imports`: A package or list of packages that the standalone file
  depends on. A minimal version may be specified in parentheses, e.g.
  `rlang (>= 1.0.0)`. These dependencies are passed to
  [`use_package()`](https://usethis.r-lib.org/dev/reference/use_package.md)
  to ensure they are included in the `Imports:` field of the
  `DESCRIPTION` file.

Note that lists are specified with standard YAML syntax, using square
brackets, for example: `imports: [rlang (>= 1.0.0), purrr]`.

## Examples

``` r
if (FALSE) { # \dontrun{
use_standalone("r-lib/rlang", file = "types-check")
use_standalone("r-lib/rlang", file = "types-check", ref = "standalone-dep")
} # }
```
