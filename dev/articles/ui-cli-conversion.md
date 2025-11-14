# Converting usethis's UI to use cli

``` r
library(usethis)
library(glue)
```

*In a hidden chunk here, I’m “exporting” some unexported internal
helpers, so that I can use them and talk about them. For similar
reasons, I attach glue above, so that certain glue functions work here,
without explicitly namespacing them.*

## Block styles

The block styles exist to produce bulleted output with a specific
symbol, using a specific color.

    > f <- function() {                                                     
    +   ui_todo("ui_todo(): red bullet")                                    
    +   ui_done("ui_done(): green check")                                   
    +   ui_oops("ui_oops(): red x")                                         
    +   ui_info("ui_info(): yellow i")                                      
    +   ui_line("ui_line(): (no symbol)")                                   
    + }                                                                     
    > f()                                                                   
    • ui_todo(): red bullet                                                 
    ✔ ui_done(): green check                                                
    ✖ ui_oops(): red x                                                      
    ℹ ui_info(): yellow i                                                   
    ui_line(): (no symbol)                                                  

Another important feature is that all of this output can be turned off
package-wide via the `usethis.quiet` option.

    > withr::with_options(                                                  
    +   list(usethis.quiet = TRUE),                                         
    +   ui_info("You won't see this message.")                              
    + )                                                                     
    > withr::with_options(                                                  
    +   list(usethis.quiet = FALSE), # this is the default                  
    +   ui_info("But you will see this one.")                               
    + )                                                                     
    ℹ But you will see this one.                                            

These styles are very close to what can be done with
[`cli::cli_bullets()`](https://cli.r-lib.org/reference/cli_bullets.html)
and the way it responds to the names of its input `text`.

    > cli::cli_bullets(c(                                                   
    +         "noindent",                                                   
    +   " " = "indent",                                                     
    +   "*" = "bullet",                                                     
    +   ">" = "arrow",                                                      
    +   "v" = "success",                                                    
    +   "x" = "danger",                                                     
    +   "!" = "warning",                                                    
    +   "i" = "info"                                                        
    + ))                                                                    
    noindent                                                                
      indent                                                                
    • bullet                                                                
    → arrow                                                                 
    ✔ success                                                               
    ✖ danger                                                                
    ! warning                                                               
    ℹ info                                                                  

A direct translation would look something like this:

| Legacy `ui_*()`                                                               | `cli_bullets()` shortcode | tweaks needed                                                                                                                                              |
|-------------------------------------------------------------------------------|---------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`ui_todo()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md) | `*`                       | blue (default) -\> red                                                                                                                                     |
| [`ui_done()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md) | `v`                       | perfect match                                                                                                                                              |
| [`ui_oops()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md) | `x`                       | perfect match                                                                                                                                              |
| [`ui_info()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md) | `i`                       | blue (default) -\> yellow                                                                                                                                  |
| [`ui_line()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md) | (unnamed)                 | sort of a perfect match? although sometimes [`ui_line()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md) is used just to get a blank line |

The overall conversion plan is to switch to a new function,
`ui_bullets()`, which is a wrapper around
[`cli::cli_bullets()`](https://cli.r-lib.org/reference/cli_bullets.html),
that adds a few features:

- Early exit, without emitting messages, if the `usethis.quiet` option
  is `TRUE`.
- A usethis theme, that changes the color of certain bullet styles and
  adds a new style for todo’s.

    > ui_bullets(c(                                                         
    +   "v" = "A great success!",                                           
    +   "_" = "Something you need to do.",                                  
    +   "x" = "Bad news.",                                                  
    +   "i" = "The more you know.",                                         
    +   " " = "I'm just here for the indentation.",                         
    +   "No indentation at all. Not used much in usethis."                  
    + ))                                                                    
    ✔ A great success!                                                      
    ☐ Something you need to do.                                             
    ✖ Bad news.                                                             
    ℹ The more you know.                                                    
      I'm just here for the indentation.                                    
    No indentation at all. Not used much in usethis.                        

Summary of what I’ve done for todo’s:

- Introduce a new bullet shortcode for a todo. Proposal: `_` (instead of
  `*`), which seems to be the best single ascii character that evokes a
  place to check something off.
- Use `cli::symbol$checkbox_off` as the symbol (instead of a generic
  bullet). I guess it will continue to be red.

In terms of the block styles, that just leaves
[`ui_code_block()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md),
which is pretty different.
[`ui_code_block()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
is used to put some code on the screen and optionally place it on the
clipboard. I have created a new function, `ui_code_snippet()` that is
built around `cli::code_block()`. Main observations:

- `cli::code_block(language = "R")` applies syntax highlighting and
  hyperlinks (e.g. to function help topics) to R code, which is cool.
  Therefore the `language` argument is also exposed in
  `ui_code_snippet()`, defaulting to `"R"`. Use `""` for anything that’s
  not R code:
        > ui_code_snippet("x <- 1 + 2")                                         
          x <- 1 + 2                                                            
        > ui_code_snippet("#include <blah.h>", language = "")                   
          #include <blah.h>                                                     
        
- `ui_code_snippet()` takes a scalar glue-type template string or a
  vector of lines. Note that the two calls below produce the same
  output.
        > ui_code_snippet("                                                     
        +   options(                                                            
        +     warnPartialMatchArgs = TRUE,                                      
        +     warnPartialMatchDollar = TRUE,                                    
        +     warnPartialMatchAttr = TRUE                                       
        +   )")                                                                 
          options(                                                              
            warnPartialMatchArgs = TRUE,                                        
            warnPartialMatchDollar = TRUE,                                      
            warnPartialMatchAttr = TRUE                                         
          )                                                                     
        > # produces same result as                                             
        > ui_code_snippet(c(                                                    
        +   "options(",                                                         
        +   "  warnPartialMatchArgs = TRUE,",                                   
        +   "  warnPartialMatchDollar = TRUE,",                                 
        +   "  warnPartialMatchAttr = TRUE",                                    
        +   ")"))                                                               
          options(                                                              
            warnPartialMatchArgs = TRUE,                                        
            warnPartialMatchDollar = TRUE,                                      
            warnPartialMatchAttr = TRUE                                         
          )                                                                     
        
- `ui_code_snippet()` does glue interpolation, by default, before
  calling
  [`cli::cli_code()`](https://cli.r-lib.org/reference/cli_code.html),
  which means you have to think about your use of `{` and `}`. If you
  want literal `{` or `}`:
  - Use `interpolate = FALSE`, if you don’t need interpolation.
  - Do the usual glue thing and double them, i.e. `{{` or `}}`.
  - If this becomes a real pain, open an issue/PR about adding `.open`
    and `.close` as arguments to `ui_code_snippet()`.

## Utility functions

The block style functions all route through some unexported utility
functions.

`is_quiet()` just consults the `usethis.quiet` option and implements the
default of `FALSE`.

``` r
is_quiet <- function() {
  isTRUE(getOption("usethis.quiet", default = FALSE))
}
```

`ui_bullet()` is an intermediate helper used by
[`ui_todo()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md),
[`ui_done()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md),
[`ui_oops()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
and
[`ui_info()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md).
It does some hygiene related to indentation (using the `indent()`
utility function), then calls `ui_inform()`.
[`ui_line()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
and
[`ui_code()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
both call `ui_inform()` directly.

`ui_inform()` is just a wrapper around
[`rlang::inform()`](https://rlang.r-lib.org/reference/abort.html) that
is guarded by a call to `is_quiet()`

``` r
ui_inform <- function(...) {
  if (!is_quiet()) {
    inform(paste0(...))
  }
  invisible()
}
```

Other than `is_quiet()`, which will continue to play the same role, I
anticipate that we no longer need these utilities (`indent()`,
`ui_bullet()`, `ui_inform()`). Updates from the future:

- `indent()` turns out to still be useful in `ui_code_snippet()`, so
  I’ve inlined it there, to avoid any reliance on definitions in
  ui-legacy.R.
- `ui_bullet()` has been renamed to `ui_legacy_bullet()` for
  auto-completion happiness with the new `ui_bullets()`.

Let’s cover
[`ui_silence()`](https://usethis.r-lib.org/dev/reference/ui_silence.md)
while we’re here, which *is* exported. It’s just a `withr::with_*()`
function for executing `code` with `usethis.quiet = TRUE`.

``` r
ui_silence <- function(code) {
  withr::with_options(list(usethis.quiet = TRUE), code)
}
```

## Inline styles

### Legacy functions

usethis has its own inline styles (mostly) for use inside functions like
[`ui_todo()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md):

- [`ui_field()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
- [`ui_value()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
- [`ui_path()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
- [`ui_code()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
- [`ui_unset()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)

    > new_val <- "oxnard"                                                   
    > x <- glue("{ui_field('name')} set to {ui_value(new_val)}")            
    > dput(x)                                                               
    structure("\033[32mname\033[39m set to \033[34m'oxnard'\033[39m", class 
    = c("glue",                                                             
    "character"))                                                           
    > ui_done(x)                                                            
    ✔ name set to 'oxnard'                                                  

The inline styles enact some combination of:

- Color, e.g. `crayon::green(x)`
- Collapsing a collection of things to one thing,
  e.g. `c("a", "b", "c")` to “a, b, c”
- Quoting, e.g. `encodeString(x, quote = "'")`

[`ui_path()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
is special because it potentially modifies the input before styling it.
[`ui_path()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
first makes the path relative to a specific base (by default, the active
project root) and, if the path is a directory, it also ensures there is
a trailing `/`.

[`ui_unset()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
is a special purpose helper used when we need to report that something
is unknown, not configured, nonexistent, etc.

    > x <- glue("Your super secret password is {ui_unset()}.")              
    > dput(x)                                                               
    structure("Your super secret password is \033[90m<unset>\033[39m.", clas
    s = c("glue",                                                           
    "character"))                                                           
    > ui_info(x)                                                            
    ℹ Your super secret password is <unset>.                                

### cli replacements

In general, we can move towards cli’s native inline-markup:
<https://cli.r-lib.org/reference/inline-markup.html>

Here’s the general conversion plan:

- [`ui_field()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
  becomes `{.field blah}`. In `usethis_theme()`, I tweak the `.field`
  style to apply single quotes if color is not available, which is what
  [`ui_field()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
  has always done.

- [`ui_value()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
  becomes `{.val value}`.

- [`ui_path()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
  is connected to `{.path path/to/thing}`, but, as explained above,
  [`ui_path()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
  also does more. Therefore, I abstracted the “path math” into an
  internal helper, `ui_path_impl()`, which is aliased to `pth()` for
  compactness. Here’s a typical conversion:

  ``` r
  # using legacy functions
  ui_done("Setting {ui_field('LazyData')} to \\
           {ui_value('true')} in {ui_path('DESCRIPTION')}")
  # using new cli-based ui
  ui_bullets(c(
    "v" = "Setting {.field LazyData} to {.val true} in {.path {pth('DESCRIPTION')}}."
  ))
  ```

  It would be nice to create a custom inline class,
  e.g. `{.ui_path {some_path}}`, which I have done in, e.g.,
  googledrive. But it’s not easy to do this *while still inheriting
  cli’s `file:` hyperlink behaviour*, which is very desirable. So that
  leads to the somewhat clunky, verbose pattern above, but it gives a
  nice result.

- [`ui_code()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
  gets replaced by various inline styles, depending on what the actual
  goal is, such as:

  - `{.code some_text}`
  - `{.arg some_argument}`
  - `{.cls some_class}`
  - `{.fun devtools::build_readme}`
  - `{.help some_function}`
  - `{.run usethis::usethis_function()}`
  - `{.topic some_topic}`
  - `{.var some_variable}`

- [`ui_unset()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
  is replaced by `ui_special()`, which you’ll see more of below.
  Currently the intended grey color doesn’t show up when I render this
  document using solarized-dark and so far I can’t get to the bottom of
  that :( Why isn’t it the same grey as “\[Copied to clipboard\]” in
  `ui_code_snippet()`, which does work?

## Conditions

I’m moving from
[`ui_stop()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md):

``` r
ui_stop <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  cnd <- structure(
    class = c("usethis_error", "error", "condition"),
    list(message = x)
  )

  stop(cnd)
}
```

to `ui_abort()`:

``` r
ui_abort <- function(message, ..., class = NULL, .envir = parent.frame()) {
  cli::cli_div(theme = usethis_theme())
  # bullet naming gymnastics, see below
  cli::cli_abort(
    message,
    class = c(class, "usethis_error"),
    .envir = .envir,
    ...
  )
}
```

The main point of `ui_abort()` is to use to `cli_abort()` (and to
continue applying the `"usethis_error"` class).

I also use `ui_abort()` to apply different default bullet
naming/styling. Starting with `"x"` and then defaulting to `"i"` seems
to fit best with usethis’s existing errors.

    > block_start = "# <<<"                                                 
    > block_end = "# >>>"                                                   
    > ui_abort(c(                                                           
    +   "Invalid block specification.",                                     
    +   "Must start with {.code {block_start}} and end with {.code {block_en
    d}}."                                                                   
    + ))                                                                    
    Error:                                                                  
    ✖ Invalid block specification.                                          
    ℹ Must start with `# <<<` and end with `# >>>`.                         
    Run `rlang::last_trace()` to see where the error occurred.              

Any bullets that are explicitly given are honored.

    atever."))                                                              
    Error:                                                                  
    ✔ It's weird to give a green check in an error, but whatever.           
    Run `rlang::last_trace()` to see where the error occurred.              
    > ui_abort(c(                                                           
    +   "!" = "Things are not ideal.",                                      
    +   ">" = "Look at me!"                                                 
    + ))                                                                    
    Error:                                                                  
    ! Things are not ideal.                                                 
    → Look at me!                                                           
    Run `rlang::last_trace()` to see where the error occurred.              

[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) and
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
start with `"!"` by default, then use `"*"` and `" "`, respectively.

The legacy functions also include
[`ui_warn()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md).
It has very little usage and, instead of converting it, I’ve eliminated
its use altogether in favor of a `"!"` bullet:

    > ui_bullets(c("!" = "The guy she told you not to worry about."))       
    ! The guy she told you not to worry about.                              

Sidebar: Now that I’m looking at a lot of the new errors with
`ui_abort()` I realize that usethis also needs to be passing the `call`
argument along. I’m going to leave that for a future, separate effort.

## Sitrep and format helpers

This is a small clump of functions that support sitrep-type output.

- `hd_line()` *unexported and, apparently, unused! now removed*
- `kv_line()` *unexported, so has new cli implementation*
- [`ui_unset()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md)
  *exported and succeeded by `ui_special()`*

`kv_line()` stands for “key-value line”. Here’s what it used to be:

    > kv_line_legacy <- function(key, value, .envir = parent.frame()) {     
    +   value <- if (is.null(value)) ui_unset() else ui_value(value)        
    +   key <- glue(key, .envir = .envir)                                   
    +   ui_inform(glue("{cli::symbol$bullet} {key}: {value}"))              
    + }                                                                     
    >                                                                       
    > url <- "https://github.com/r-lib/usethis.git"                         
    > remote <- "origin"                                                    
    > kv_line_legacy("URL for the {ui_value(remote)} remote", url)          
    • URL for the 'origin' remote: 'https://github.com/r-lib/usethis.git'   
    >                                                                       
    > host <- "github.com"                                                  
    > kv_line_legacy("Personal access token for {ui_value(host)}", NULL)    
    • Personal access token for 'github.com': <unset>                       

Key features:

- Interpolates data and applies inline style to the result. Works
  differently for `key` and `value`, because you’re much more likely to
  use interpolation and styling in `key` than `value`.
- Has special handling when `value` is `NULL`.
- Applies `"*"` bullet name/style to over all result.

I won’t show the updated source for `kv_line()` but here is some usage
to show what it’s capable of:

    > noun <- "thingy"                                                      
    > value <- "VALUE"                                                      
    > kv_line("Let's reveal {.field {noun}}", "whatever")                   
    • Let's reveal thingy: "whatever"                                       
    >                                                                       
    > kv_line("URL for the {.val {remote}} remote", I("{.url {url}}"))      
    • URL for the "origin" remote: <https://github.com/r-lib/usethis.git>   
    >                                                                       
    > kv_line("Personal access token for {.val {host}}", NULL)              
    • Personal access token for "github.com": <unset>                       
    >                                                                       
    > kv_line("Personal access token for {.val {host}}", ui_special("discove
    red"))                                                                  
    • Personal access token for "github.com": <discovered>                  

`ui_special()` is the successor to
[`ui_unset()`](https://usethis.r-lib.org/dev/reference/ui-legacy-functions.md).

## Questions

There’s currently no drop-in substitute for
[`ui_yeah()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)
and
[`ui_nope()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)
in cli. Related issues: <https://github.com/r-lib/cli/issues/228>,
<https://github.com/r-lib/cli/issues/488>. Therefore, in the meantime,
[`ui_yeah()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)
and
[`ui_nope()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)
are not-quite-superseded for external users.

However, internally, I’ve switched to the unexported functions
`ui_yep()` and `ui_nah()` that are lightly modified versions of
[`ui_yeah()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)
and
[`ui_nope()`](https://usethis.r-lib.org/dev/reference/ui-questions.md)
that use cli for styling.

``` r
if (ui_nope("
      Current branch ({ui_value(actual)}) is not repo's default \\
      branch ({ui_value(default_branch)}).{details}")) {
        ui_abort("Cancelling. Not on desired branch.")
    }
```

## Miscellaneous notes

- I’ve been adding a period to the end of messages, as a general rule.

- In terms of whitespace and indentation, I’ve settled on some
  conventions. The overall goal is to get the right user-facing output
  (obviously), while making it as easy as possible to *predict* what
  that’s going to look like when you’re writing the code.

  ``` r
  ui_bullets(c(
    "i" = "Downloading into {.path {pth(destdir)}}.",
    "_" = "Prefer a different location? Cancel, try again, and specify
           {.arg destdir}."
  ))
  ...
  ui_bullets(c("x" = "Things are very wrong."))
  ```

  Key points:

  - Put `ui_bullets(c(` on its own line, then all of the bullet items,
    followed by `))` on its own line. Sometimes I make an exception for
    a bullet list with exactly one, short bullet item.

  - Use hard line breaks inside bullet text to comply with surrounding
    line length. In subsequent lines, use indentation to get you just
    past the opening `"`. This extraneous white space is later
    rationalized by cli, which handles wrapping.

  - Surround bullet names like `x` and `i` with quotes, even though you
    don’t have to, because it’s required for other names, such as `!` or
    `_` and it’s better to be consistent.

  - Here’s another style I like that applies to `ui_abort()`, where
    there’s just one, unnamed bullet, but the call doesn’t fit on one
    line.

    ``` r
    pr <- list(pr_number = 13)
    ui_abort("
      The repo or branch where PR #{pr$pr_number} originates seems to have been
      deleted.")
    ```
