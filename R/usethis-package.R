#' @keywords internal
#' @importFrom glue glue
#' @importFrom fs path file_temp file_exists is_dir dir_create path_dir
#' @importFrom fs path_file file_create
"_PACKAGE"

.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, "dir.exists")
}
