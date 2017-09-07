#' Create a simple `NEWS.md`
#'
#' This creates a basic `NEWS.md` in the root directory.
#'
#' @inheritParams use_template
#' @export
use_news_md <- function(base_path = ".") {
  use_template(
    "NEWS.md",
    data = package_data(base_path),
    open = TRUE,
    base_path = base_path
  )
}

use_news_heading <- function(version, base_path = ".") {
  news_path <- file.path(base_path, "NEWS.md")
  if (!file.exists(news_path)) {
    return(invisible())
  }

  news <- readLines(news_path)
  title <- paste0("# ", project_name(base_path), " ", version)

  if (title == news[[1]]) {
    return(invisible())
  }

  done("Adding new heading to NEWS.md")
  write_utf8(news_path, c(title, "", news))
}
