#' Use tidyverse tibbles in your package
#'
#' Does setup necessary to use the tidyverse's tibble internally in your package and to
#' enable tibble printing out of the box:
#' * Adds tibble to "Imports" in DESCRIPTION
#' * Creates `R/utils-tibble.R` with the necessary roxygen template
#'
#' @export
use_tibble <- function() {
  check_is_package("use_tibble()")
  if (!uses_roxygen()) {
    stop(code("use_tibble()"), " requires that you use roxygen", call. = FALSE)
  }

  use_dependency("tibble", "Imports")
  use_template("tibble.R", "R/utils-tibble.R")

  todo("Run ", code("document()"))
}
