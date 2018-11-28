#' Helpers to make useful changes to `.Rprofile`
#'
#' All functions open your `.Rprofile` and gives you the code you need to
#' paste in.
#' * `use_usethis()`: makes usethis available in interactive sessions.
#' * `use_partial_warning()`: warn on partial matches.
#'
#' @name rprofile-helper
NULL

#' @rdname rprofile-helper
#' @export
use_usethis <- function() {
  edit_r_profile("user")

  todo(
    "Include this code in {value('.Rprofile')} to make {field('usethis')} ",
    "available in all interactive sessions"
  )
  ## in glue, you get a literal brace by using doubled braces
  code_block(
    "if (interactive()) {{",
    "  suppressMessages(require(usethis))",
    "}}"
  )
}

#' @rdname rprofile-helper
#' @export
use_partial_warnings <- function() {
  edit_r_profile("user")

  todo(
    "Include this code in {value('.Rprofile')} to warn on partial matches"
  )
  ## in glue, you get a literal brace by using doubled braces
  code_block(
    "options(",
    "  warnPartialMatchArgs = TRUE,",
    "  warnPartialMatchDollar = TRUE,",
    "  warnPartialMatchAttr = TRUE",
    ")"
  )
}
