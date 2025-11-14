# Initialise a git repository

`use_git()` initialises a Git repository and adds important files to
`.gitignore`. If user consents, it also makes an initial commit.

## Usage

``` r
use_git(message = "Initial commit")
```

## Arguments

- message:

  Message to use for first commit.

## See also

Other git helpers:
[`use_git_config()`](https://usethis.r-lib.org/dev/reference/use_git_config.md),
[`use_git_hook()`](https://usethis.r-lib.org/dev/reference/use_git_hook.md),
[`use_git_ignore()`](https://usethis.r-lib.org/dev/reference/use_git_ignore.md)

## Examples

``` r
if (FALSE) { # \dontrun{
use_git()
} # }
```
