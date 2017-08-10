#' Increment development version
#'
#' This adds ".9000" to the package \code{DESCRIPTION}, adds a new heading to
#' \code{NEWS.md} (if it exists), and then checks the result into git.
#'
#' @export
#' @inheritParams use_template
use_dev_version <- function(base_path = ".") {
  if (uses_git(base_path) && git_uncommitted(base_path)) {
    stop(
      "Uncommited changes. Please commit to git before continuing",
      call. = FALSE
    )
  }

  ver <- desc::desc_get_version(base_path)
  if (length(unlist(ver)) > 3) {
    return(invisible())
  }

  dev_ver <- paste0(ver, ".9000")

  use_description_field("Verison", dev_ver, base_path = base_path)
  use_news_heading(dev_ver, base_path = base_path)
  git_check_in(
    paths = c("DESCRIPTION", "NEWS.md"),
    message = "Use development version",
    base_path = base_path
  )

  invisible(TRUE)
}
