#' Use spell check
#'
#' Adds a unit test to automatically run a spell check on documentation and,
#' optionally, vignettes during `R CMD check`, using the
#' [spelling][spelling::spell_check_package] package. Also adds a `WORDLIST`
#' file to the package, which is a dictionary of whitelisted words. See
#' [spelling::wordlist] for details.
#'
#' @param vignettes Logical, `TRUE` to spell check all `rmd` and `rnw` files in
#'   the `vignettes/` folder.
#' @param lang Preferred spelling language. Usually either `"en-US"` or
#'   `"en-GB"`.
#' @param error Logical, indicating whether the unit test should fail if
#'   spelling errors are found. Defaults to `FALSE`, which does not error, but
#'   prints potential spelling errors
#' @export
use_spell_check <- function(vignettes = TRUE,
                            lang = "en-US",
                            error = FALSE) {
  check_is_package("use_spell_check")
  check_installed("spelling")
  use_dependency("spelling", "Suggests")
  use_description_field("Language", lang, overwrite = TRUE)
  spelling::spell_check_setup(
    pkg = proj_get(), vignettes = vignettes, lang = lang, error = error
  )
  ui_todo("Run {ui_code('devtools::check()')} to trigger spell check")
}
