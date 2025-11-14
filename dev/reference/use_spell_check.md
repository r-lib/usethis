# Use spell check

Adds a unit test to automatically run a spell check on documentation
and, optionally, vignettes during `R CMD check`, using the
[spelling](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
package. Also adds a `WORDLIST` file to the package, which is a
dictionary of whitelisted words. See
[spelling::wordlist](https://docs.ropensci.org/spelling//reference/wordlist.html)
for details.

## Usage

``` r
use_spell_check(vignettes = TRUE, lang = "en-US", error = FALSE)
```

## Arguments

- vignettes:

  Logical, `TRUE` to spell check all `rmd` and `rnw` files in the
  `vignettes/` folder.

- lang:

  Preferred spelling language. Usually either `"en-US"` or `"en-GB"`.

- error:

  Logical, indicating whether the unit test should fail if spelling
  errors are found. Defaults to `FALSE`, which does not error, but
  prints potential spelling errors
