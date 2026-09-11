# Test coverage

Adds test coverage reporting to a package, using either Codecov
(`https://codecov.io`) or Coveralls (`https://coveralls.io`).

## Usage

``` r
use_coverage(type = c("codecov", "coveralls"), repo_spec = NULL)

use_covr_ignore(files)
```

## Arguments

- type:

  Which web service to use.

- repo_spec:

  Optional GitHub repo specification in this form: `owner/repo`. This
  can usually be inferred from the GitHub remotes of active project.

- files:

  Character vector of file globs.
