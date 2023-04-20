#' Create a CITATION template
#'
#' Use this if you want to encourage users of your package to cite an
#' article or book.
#'
#' @export
use_citation <- function() {
  check_is_package()

  use_directory("inst")
  use_template(
    "citation-template.R",
    path("inst", "CITATION"),
    open = TRUE
  )
}
