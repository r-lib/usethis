#' Use a basic `NAMESPACE`
#'
#' This `NAMESPACE` exports everything, except functions that start
#' with a `.`.
#'
#' @export
use_namespace <- function() {
  check_is_package("use_namespace()")
  use_template("NAMESPACE")
}
