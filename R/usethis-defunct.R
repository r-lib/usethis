#' Defunct functions in usethis
#'
#' These functions are marked as defunct and have been removed from usethis.
#'
#' @name usethis-defunct
#' @keywords internal
NULL

#' This function is defunct
#' @rdname usethis-defunct
#' @export
use_depsy_badge <- function() {
  msg <- glue(
    "The Depsy project has officially concluded and is no longer ",
    "being maintained. Therefore {ui_code('use_depsy_badge()')}",
    " has been removed from usethis."
  )
  .Defunct(msg = msg)
}

deprecate_warn_credentials <- function(whos_asking, details = NULL) {
  whos_asking <- sub("[()]+$", "", whos_asking)
  what <- glue("{whos_asking}(credentials = )")
  deets <- glue("
    usethis now uses the gert package for Git operations, instead of git2r, and
    gert relies on the credentials package for auth. Therefore git2r credentials
    are no longer accepted.
    ")

  lifecycle::deprecate_warn(
    "1.7.0",
    "use_github(credentials = )",
    details = details %||% deets
  )
}

