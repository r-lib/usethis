#' Helpers to make useful changes to `.Rprofile`
#'
#' @description
#' All functions open your `.Rprofile` and give you the code you need to
#' paste in.
#'
#' * `use_devtools()`: makes devtools available in interactive sessions.
#' * `use_usethis()`: makes usethis available in interactive sessions.
#' * `use_reprex()`: makes reprex available in interactive sessions.
#' * `use_conflicted()`:  makes conflicted available in interactive sessions.
#' * `use_partial_warnings()`: warns on partial matches.
#'
#' @name rprofile-helper
NULL

#' @rdname rprofile-helper
#' @export
use_conflicted <- function() {
  use_rprofile_package("conflicted")
}

#' @rdname rprofile-helper
#' @export
use_reprex <- function() {
  use_rprofile_package("reprex")
}

#' @rdname rprofile-helper
#' @export
use_usethis <- function() {
  use_rprofile_package("usethis")
}

#' @rdname rprofile-helper
#' @export
use_devtools <- function() {
  use_rprofile_package("devtools")
}

use_rprofile_package <- function(package) {
  check_installed(package)
  ui_todo(
    "Include this code in {ui_value('.Rprofile')} to make \\
    {ui_field(package)} available in all interactive sessions."
  )
  ui_code_block(
    "
    if (interactive()) {{
      suppressMessages(require({package}))
    }}
    "
  )
  edit_r_profile("user")
}

#' @rdname rprofile-helper
#' @export
use_partial_warnings <- function() {
  ui_todo(
    "Include this code in {ui_path('.Rprofile')} to warn on partial matches."
  )
  ui_code_block(
    "
    options(
      warnPartialMatchArgs = TRUE,
      warnPartialMatchDollar = TRUE,
      warnPartialMatchAttr = TRUE
    )
    "
  )
  edit_r_profile("user")
}
