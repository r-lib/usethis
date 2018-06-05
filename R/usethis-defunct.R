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
    "being maintained. Therefore {code('use_depsy_badge()')}",
    " has been removed from usethis."
  )
  .Defunct(msg = msg)
}
