# Use magrittr's pipe in your package

**\[deprecated\]**

The base R pipe has been available since R 4.1.0 and we recommend using
it in all actively maintained and new work, both inside and outside
packages. The `magrittr` pipe (`%>%`) can usually just be replaced with
base R's `|>`, with a few things to keep in mind:

- Instead of `x %>% f`, use `x |> f()`.

- Instead of `x %>% f(1, y = .)`, use `x |> f(1, y = _)`.

- Instead of `x %>% f(a = ., b = .)`, define a new helper function.

Learn more in
<https://www.tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/>.

## Usage

``` r
use_pipe(export = TRUE)
```

## Arguments

- export:

  If `TRUE`, the file `R/utils-pipe.R` is added, which provides the
  roxygen template to import and re-export `%>%`. If `FALSE`, the
  necessary roxygen directive is added, if possible, or otherwise
  instructions are given.

## Examples

``` r
if (FALSE) { # \dontrun{
use_pipe()
} # }
```
