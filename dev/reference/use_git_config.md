# Configure Git

Sets Git options, for either the user or the project ("global" or
"local", in Git terminology). Wraps
[`gert::git_config_set()`](https://docs.ropensci.org/gert/reference/git_config.html)
and
[`gert::git_config_global_set()`](https://docs.ropensci.org/gert/reference/git_config.html).
To inspect Git config, see
[`gert::git_config()`](https://docs.ropensci.org/gert/reference/git_config.html).

## Usage

``` r
use_git_config(scope = c("user", "project"), ...)
```

## Arguments

- scope:

  Edit globally for the current **user**, or locally for the current
  **project**

- ...:

  Name-value pairs, processed as
  \<[`dynamic-dots`](https://rlang.r-lib.org/reference/dyn-dots.html)\>.

## Value

Invisibly, the previous values of the modified components, as a named
list.

## See also

Other git helpers:
[`use_git()`](https://usethis.r-lib.org/dev/reference/use_git.md),
[`use_git_hook()`](https://usethis.r-lib.org/dev/reference/use_git_hook.md),
[`use_git_ignore()`](https://usethis.r-lib.org/dev/reference/use_git_ignore.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# set the user's global user.name and user.email
use_git_config(user.name = "Jane", user.email = "jane@example.org")

# set the user.name and user.email locally, i.e. for current repo/project
use_git_config(
  scope = "project",
  user.name = "Jane",
  user.email = "jane@example.org"
)
} # }
```
