# Add a git hook

Sets up a git hook using the specified script. Creates a hook directory
if needed, and sets correct permissions on hook.

## Usage

``` r
use_git_hook(hook, script)
```

## Arguments

- hook:

  Hook name. One of "pre-commit", "prepare-commit-msg", "commit-msg",
  "post-commit", "applypatch-msg", "pre-applypatch", "post-applypatch",
  "pre-rebase", "post-rewrite", "post-checkout", "post-merge",
  "pre-push", "pre-auto-gc".

- script:

  Text of script to run

## See also

Other git helpers:
[`use_git()`](https://usethis.r-lib.org/dev/reference/use_git.md),
[`use_git_config()`](https://usethis.r-lib.org/dev/reference/use_git_config.md),
[`use_git_ignore()`](https://usethis.r-lib.org/dev/reference/use_git_ignore.md)
