#' Add files to \code{.Rbuildignore}
#'
#' \code{.Rbuildignore} has a regular expression on each line, but it's
#' usually easier to work with specific file names. By default,
#' \code{use_build_ignore} will (crudely) turn a filename into a regular
#' expression that will only match that path. Repeated entries will be
#' silently removed.
#'
#' @param base_path Base path to package root.
#' @param files Character vector of path naems.
#' @param escape If \code{TRUE}, the default, will escape \code{.} to
#'   \code{\\.} and surround with \code{^} and \code{$}.
#' @export
#' @aliases add_build_ignore
#' @family infrastructure
#' @keywords internal
use_build_ignore <- function(files, escape = TRUE, base_path = ".") {
  if (escape) {
    files <- escape_path(files)
  }

  path <- file.path(base_path, ".Rbuildignore")
  union_write(path, files)

  invisible(TRUE)
}

escape_path <- function(x) {
  x <- gsub("\\.", "\\\\.", x)
  paste0("^", x, "$")
}
