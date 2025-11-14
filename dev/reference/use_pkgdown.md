# Use pkgdown

[pkgdown](https://pkgdown.r-lib.org) makes it easy to turn your package
into a beautiful website. usethis provides two functions to help you use
pkgdown:

- `use_pkgdown()`: creates a pkgdown config file and adds relevant files
  or directories to `.Rbuildignore` and `.gitignore`.

- `use_pkgdown_github_pages()`: implements the GitHub setup needed to
  automatically publish your pkgdown site to GitHub pages:

  - (first, it calls `use_pkgdown()`)

  - [`use_github_pages()`](https://usethis.r-lib.org/dev/reference/use_github_pages.md)
    prepares to publish the pkgdown site from the `gh-pages` branch

  - [`use_github_action("pkgdown")`](https://usethis.r-lib.org/dev/reference/use_github_action.md)
    configures a GitHub Action to automatically build the pkgdown site
    and deploy it via GitHub Pages

  - The pkgdown site's URL is added to the pkgdown configuration file,
    to the URL field of DESCRIPTION, and to the GitHub repo.

  - Packages owned by certain GitHub organizations (tidyverse, r-lib,
    and tidymodels) get some special treatment, in terms of anticipating
    the (eventual) site URL and the use of a pkgdown template.

## Usage

``` r
use_pkgdown(config_file = "_pkgdown.yml", destdir = "docs")

use_pkgdown_github_pages()
```

## Arguments

- config_file:

  Path to the pkgdown yaml config file, relative to the project.

- destdir:

  Target directory for pkgdown docs.

## See also

<https://pkgdown.r-lib.org/articles/pkgdown.html#configuration>
