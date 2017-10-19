#' Create package documentation template
#'
#' Adds a roxygen template for package documentation. When you `document()`
#' roxygen will flesh out the Rd file using data from the `DESCRIPTION`.
#' That ensures you don't need to repeat the same information in multiple
#' places. This block is a good place to put global namespace tags like
#' `@importFrom`.
#'
#' @inheritParams use_template
#' @export
use_package_doc <- function() {
  name <- project_name()

  use_template(
    "packagename-package.R",
    file.path("R", paste0(name, "-package.R")),
    data = list(name = name)
  )
}
