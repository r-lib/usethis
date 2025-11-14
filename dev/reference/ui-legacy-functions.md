# Legacy functions related to user interface

**\[superseded\]**

These functions are now superseded. External users of the
`usethis::ui_*()` functions are encouraged to use the [cli
package](https://cli.r-lib.org/) instead. The cli package did not have
the required functionality when the `usethis::ui_*()` functions were
created, but it has had that for a while now and it's the superior
option. There is even a cli vignette about how to make this transition:
[`vignette("usethis-ui", package = "cli")`](https://cli.r-lib.org/articles/usethis-ui.html).

usethis itself now uses cli internally for its UI, but these new
functions are not exported and presumably never will be. There is a
developer-focused article on the process of transitioning usethis's own
UI to use cli: [Converting usethis's UI to use
cli](https://usethis.r-lib.org/articles/ui-cli-conversion.html).

## Usage

``` r
ui_line(x = character(), .envir = parent.frame())

ui_todo(x, .envir = parent.frame())

ui_done(x, .envir = parent.frame())

ui_oops(x, .envir = parent.frame())

ui_info(x, .envir = parent.frame())

ui_code_block(x, copy = rlang::is_interactive(), .envir = parent.frame())

ui_stop(x, .envir = parent.frame())

ui_warn(x, .envir = parent.frame())

ui_field(x)

ui_value(x)

ui_path(x, base = NULL)

ui_code(x)

ui_unset(x = "unset")
```

## Arguments

- x:

  A character vector.

  For block styles, conditions, and questions, each element of the
  vector becomes a line, and the result is processed by
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html). For
  inline styles, each element of the vector becomes an entry in a comma
  separated list.

- .envir:

  Used to ensure that
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) gets
  the correct environment. For expert use only.

- copy:

  If `TRUE`, the session is interactive, and the clipr package is
  installed, will copy the code block to the clipboard.

- base:

  If specified, paths will be displayed relative to this path.

## Value

The block styles, conditions, and questions are called for their
side-effect. The inline styles return a string.

## Details

The `ui_` functions can be broken down into four main categories:

- block styles: `ui_line()`, `ui_done()`, `ui_todo()`, `ui_oops()`,
  `ui_info()`.

- conditions: `ui_stop()`, `ui_warn()`.

- questions:
  [`ui_yeah()`](https://usethis.r-lib.org/dev/reference/ui-questions.md),
  [`ui_nope()`](https://usethis.r-lib.org/dev/reference/ui-questions.md).

- inline styles: `ui_field()`, `ui_value()`, `ui_path()`, `ui_code()`,
  `ui_unset()`.

The question functions
[`ui_yeah()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)
and
[`ui_nope()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)
have their own [help
page](https://usethis.r-lib.org/dev/reference/ui-questions.md).

All UI output (apart from
[`ui_yeah()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)/[`ui_nope()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)
prompts) can be silenced by setting `options(usethis.quiet = TRUE)`. Use
[`ui_silence()`](https://usethis.r-lib.org/dev/reference/ui_silence.md)
to silence selected actions.

## Examples

``` r
new_val <- "oxnard"
ui_done("{ui_field('name')} set to {ui_value(new_val)}")
#> ✔ name set to 'oxnard'
ui_todo("Redocument with {ui_code('devtools::document()')}")
#> • Redocument with `devtools::document()`

ui_code_block(c(
  "Line 1",
  "Line 2",
  "Line 3"
))
#>   Line 1
#>   Line 2
#>   Line 3
```
