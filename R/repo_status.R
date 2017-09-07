#' Create a Repository badge
#'
#' This prints out the markdown which will display a Repo "badge", indicating
#' the states of usability and development, powered by
#' \url{http://www.repostatus.org}.
#' @param status Status of repository, see \url{http://www.repostatus.org}
#'
#' @inheritParams use_template
#' @export
use_repo_status_badge <- function(
  status = c(
    "active", "abandoned", "concept",
    "inactive", "moved", "suspended",
    "unsupported", "wip")
  ) {

  status = match.arg(status)
  src <- paste0("http://www.repostatus.org/badges/latest/", status, ".svg")
  href <- paste0("http://www.repostatus.org/#", status)
  use_badge("Repo status", href = href, src = src)

  invisible(TRUE)
}
