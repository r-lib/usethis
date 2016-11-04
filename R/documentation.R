#' Create package documentation template
#'
#' Adds a roxygen template for package documentation. When you \code{document()}
#' roxygen will flesh out the Rd file using data from the \code{DESCRIPTION}.
#' That ensures you don't need to repeat the same information in multiple
#' places. This block is a good place to put global namespace tags like
#' \code{@importFrom}.
#'
#' @inheritParams use_template
#' @export
use_package_doc <- function(base_path = ".") {
  name <- package_name(base_path)

  use_template(
    "packagename-package.r",
    file.path("R", paste0(name, "-package.r")),
    data = list(name = name),
    base_path = base_path
  )
}
