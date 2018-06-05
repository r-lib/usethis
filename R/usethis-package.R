#' @keywords internal
#' @importFrom glue glue
"_PACKAGE"

.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, "dir.exists")
}
