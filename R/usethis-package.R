#' @keywords internal
#' @importFrom glue glue
#' @importFrom fs path file_temp file_exists dir_exists is_dir
#' @importFrom fs path_file path_dir file_create dir_create path_rel as_fs_path
#' @importFrom fs path_ext path_ext_set path_ext_remove file_move path_join
#' @importFrom fs path_norm file_create path_real
"_PACKAGE"

.onLoad <- function(libname, pkgname) {
  backports::import(pkgname, "dir.exists")
}
