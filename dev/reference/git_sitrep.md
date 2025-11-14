# Git/GitHub sitrep

Get a situation report on your current Git/GitHub status. Useful for
diagnosing problems. The default is to report all values; provide values
for `tool` or `scope` to be more specific.

## Usage

``` r
git_sitrep(tool = c("git", "github"), scope = c("user", "project"))
```

## Arguments

- tool:

  Report for **git**, or **github**

- scope:

  Report globally for the current **user**, or locally for the current
  **project**

## Examples

``` r
if (FALSE) { # \dontrun{
# report all
git_sitrep()

# report git for current user
git_sitrep("git", "user")
} # }
```
