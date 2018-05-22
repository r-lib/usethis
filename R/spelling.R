#' Use Spell Check
#'
#' Adds a unit test which automatically runs a spell check on documentation and/or
#' vignettes using the [spelling][spelling::spell_check_package] package. Also adds
#' a `WORDLIST` file to the package which maintains a dictionary of whitelisted words.
#' See [spelling::wordlist] for details.
#'
#' @param vignettes also check all `rmd` and `rnw` files in the pkg vignettes folder
#' @param lang preferred spelling langage. Usually either `"en-US"` or `"en-GB"`
#' @param error should the unit test fail if spelling errors are found? Default prints
#' potential spelling errors but never errors.
#' @export
use_spell_check <- function(vignettes = TRUE, lang = "en-US", error = FALSE) {
  check_installed("spelling")
  use_dependency("spelling", "Suggests")
  use_description_field("Language", lang)
  spelling::spell_check_setup(
    pkg = proj_get(), vignettes = vignettes, lang = lang, error = error
  )
  todo("Run devtools::check() to test")
}
