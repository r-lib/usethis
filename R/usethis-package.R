#' @keywords internal
"_PACKAGE"

.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, "dir.exists")
}
