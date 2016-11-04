#' Add a file to \code{.Rbuildignore}
#'
#' \code{.Rbuildignore} has a regular expression on each line, but it's
#' usually easier to work with specific file names. By default, will (crudely)
#' turn a filename into a regular expression that will only match that
#' path. Repeated entries will be silently removed.
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @param files Name of file.
#' @param escape If \code{TRUE}, the default, will escape \code{.} to
#'   \code{\\.} and surround with \code{^} and \code{$}.
#' @return Nothing, called for its side effect.
#' @export
#' @aliases add_build_ignore
#' @family infrastructure
#' @keywords internal
use_build_ignore <- function(files, escape = TRUE, pkg = ".") {
  pkg <- as.package(pkg)

  if (escape) {
    files <- paste0("^", gsub("\\.", "\\\\.", files), "$")
  }

  path <- file.path(pkg$path, ".Rbuildignore")
  union_write(path, files)

  invisible(TRUE)
}


add_build_ignore <- function(pkg = ".", files, escape = TRUE) {
  use_build_ignore(files, escape = escape, pkg = pkg)
}



