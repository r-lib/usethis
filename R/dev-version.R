#' Increment development version
#'
#' This adds ".9000" to the package `DESCRIPTION`, adds a new heading to
#' `NEWS.md` (if it exists), and then checks the result into git.
#'
#' @export
#' @inheritParams use_template
use_dev_version <- function() {
  if (uses_git() && git_uncommitted()) {
    stop(
      "Uncommited changes. Please commit to git before continuing",
      call. = FALSE
    )
  }

  ver <- desc::desc_get_version(proj_get())
  if (length(unlist(ver)) > 3) {
    return(invisible())
  }

  dev_ver <- paste0(ver, ".9000")

  use_description_field("Verison", dev_ver)
  use_news_heading(dev_ver)
  git_check_in(
    base_path = proj_get(),
    paths = c("DESCRIPTION", "NEWS.md"),
    message = "Use development version"
  )

  invisible(TRUE)
}
