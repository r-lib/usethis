#' Create a simple \code{NEWS.md}
#'
#' This creates a basic \code{NEWS.md} in the root directory.
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
