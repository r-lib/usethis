#' Create a CITATION template
#'
#' Use this if you want to encourage users of your package to cite an
#' article or book.
#'
#' @export
use_citation <- function() {
  use_directory("inst")
  use_template(
    "CITATION",
    path("inst", "CITATION"),
    data = package_data(),
    open = TRUE
  )
}
