#' Make usethis available in interactive sessions
#'
#' Opens your `.Rprofile` and gives you the code you need to paste in.
#'
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
