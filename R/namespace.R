#' Use a basic `NAMESPACE`
#'
#' This `NAMESPACE` exports everything, except functions that start
#' with a `.`.
#'
#' @inheritParams use_template
#' @export
use_namespace <- function(base_path = ".") {
  use_template("NAMESPACE", base_path = base_path)
}
