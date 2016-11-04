#' Create package documentation template
#'
#' Adds a roxygen template for package documentation
#' @export
use_package_doc <- function(pkg = ".") {
  pkg <- as.package(pkg)

  use_template(
    "packagename-package.r",
    file.path("R", paste(pkg$package, "-package.r", sep = "")),
    data = list(name = pkg$package),
    open = TRUE,
    pkg = pkg
  )
}
