#' Use tidyverse tibbles in your package
#'
#' Does setup necessary to deal in objects of type `tbl_df` or "tibble" from
#' your package. The tibble is the tidyverse's variant of the `data.frame`.
#' `use_tibble()` ensures that tibbles returned by your package will use the
#' tibble print method. Specifically, this function:
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
