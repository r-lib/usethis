#' @keywords internal
#' @importFrom glue glue
#' @importFrom fs path file_temp file_exists
"_PACKAGE"

.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, "dir.exists")
}
