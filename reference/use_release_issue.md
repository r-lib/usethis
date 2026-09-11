# Create a release checklist in a GitHub issue

When preparing to release a package to CRAN there are quite a few steps
that need to be performed, and some of the steps can take multiple
hours. This function creates a checklist in a GitHub issue to:

- Help you keep track of where you are in the process

- Feel a sense of satisfaction as you progress towards final submission

- Help watchers of your package stay informed.

The checklist contains a generic set of steps that we've found to be
helpful, based on the type of release ("patch", "minor", or "major").
You're encouraged to edit the issue to customize this list to meet your
needs.

### Customization

- If you want to consistently add extra bullets for every release, you
  can include your own custom bullets by providing an (unexported)
  `release_bullets()` function that returns a character vector. (For
  historical reasons, `release_questions()` is also supported).

- If you want to check additional packages in the revdep check process,
  provide an (unexported) `release_extra_revdeps()` function that
  returns a character vector. This is currently only supported for Posit
  internal check tooling.

## Usage

``` r
use_release_issue(version = NULL)
```

## Arguments

- version:

  Optional version number for release. If unspecified, you can make an
  interactive choice.

## Examples

``` r
if (FALSE) { # \dontrun{
use_release_issue("2.0.0")
} # }
```
