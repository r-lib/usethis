#' Use a basic `NAMESPACE`
#'
#' This `NAMESPACE` exports everything, except functions that start
#' with a `.`.
#'
#' @seealso The [namespace chapter](http://r-pkgs.had.co.nz/namespace.html) of
#'   [R Packages](http://r-pkgs.had.co.nz).
#'
#' @export
use_namespace <- function() {
  check_is_package("use_namespace()")
  use_template("NAMESPACE")
}
