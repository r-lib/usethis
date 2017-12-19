#' Use a basic `NAMESPACE`
#'
#' This `NAMESPACE` exports everything, except functions that start
#' with a `.`.
#'
#' @inheritParams use_template
#' @export
use_namespace <- function() {
  use_template("NAMESPACE")
}
