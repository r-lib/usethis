# Publish a GitHub release

Pushes the current branch (if safe) then publishes a GitHub release for
the latest CRAN submission.

If you use `devtools::submit_cran()` to submit to CRAN, information
about the submitted state is captured in a `CRAN-SUBMISSION` file.
`use_github_release()` uses this info to populate the GitHub release
notes and, after success, deletes the file. In the absence of such a
file, we assume that current state (SHA of `HEAD`, package version,
NEWS) is the submitted state.

## Usage

``` r
use_github_release(publish = TRUE)
```

## Arguments

- publish:

  If `TRUE`, publishes a release. If `FALSE`, creates a draft release.
