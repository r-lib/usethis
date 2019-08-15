#' Use a basic `NAMESPACE`
#'
#' This `NAMESPACE` exports everything, except functions that start
#' with a `.`.
#'
#' @seealso The [namespace chapter](https://r-pkgs.org/namespace.html) of
#'   [R Packages](https://r-pkgs.org).
#'
#' @export
use_namespace <- function() {
  check_is_package("use_namespace()")
  use_template("NAMESPACE")
}
