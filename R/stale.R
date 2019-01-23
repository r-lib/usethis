#' Add Stale Bot
#'
#' `use_stale()` Adds [GitHub Stale Bot](https://github.com/apps/stale) to
#' add Stale bot to your repository
#'
#' @inheritParams use_template
#' @export
use_stale <- function(open = interactive()) {
  check_uses_github()
  if (!dir.exists(".github")) {
    dir.create(".github", showWarnings = FALSE)
  }
  new <- use_template(
    "stale",
    ".github/stale.yml",
    ignore = TRUE,
    open = open
  )
  if (open) {
    utils::browseURL("https://github.com/apps/stale")
  }
  if (!new) return(invisible(FALSE))

  invisible(TRUE)
}
