# Suppress usethis's messaging

Execute a bit of code without usethis's normal messaging.

## Usage

``` r
ui_silence(code)
```

## Arguments

- code:

  Code to execute with usual UI output silenced.

## Value

Whatever `code` returns.

## Examples

``` r
# compare the messaging you see from this:
browse_github("usethis")
#> ☐ Open URL <https://github.com/r-lib/usethis>.
# vs. this:
ui_silence(
  browse_github("usethis")
)
```
