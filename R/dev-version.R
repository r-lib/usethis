#' Increment to a development version
#'
#' This adds ".9000" to the "Version" field in `DESCRIPTION`, adds a new heading
#' to `NEWS.md` (if it exists), and then checks the result into git.
#'
#' @export
use_dev_version <- function() {
  check_is_package("use_dev_version()")
  check_uncommitted_changes()

  ver <- desc::desc_get_version(proj_get())
  if (length(unlist(ver)) > 3) {
    return(invisible())
  }

  dev_ver <- paste0(ver, ".9000")

  use_description_field("Version", dev_ver, overwrite = TRUE)
  use_news_heading(dev_ver)
  git_check_in(
    base_path = proj_get(),
    paths = c("DESCRIPTION", "NEWS.md"),
    message = "Use development version"
  )

  invisible(TRUE)
}
