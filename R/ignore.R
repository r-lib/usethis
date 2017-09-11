#' Add files to `.Rbuildignore`
#'
#' `.Rbuildignore` has a regular expression on each line, but it's
#' usually easier to work with specific file names. By default,
#' `use_build_ignore` will (crudely) turn a filename into a regular
#' expression that will only match that path. Repeated entries will be
#' silently removed.
#'
#' @param files Character vector of path names.
#' @param escape If `TRUE`, the default, will escape `.` to
#'   `\\.` and surround with `^` and `$`.
#' @inheritParams use_template
#' @export
use_build_ignore <- function(files, escape = TRUE, base_path = ".") {
  if (escape) {
    files <- escape_path(files)
  }

  write_union(base_path, ".Rbuildignore", files)
}

escape_path <- function(x) {
  x <- gsub("\\.", "\\\\.", x)
  x <- gsub("/$", "", x)
<<<<<<< HEAD
  # maintain absolute path on windows to keep double \\ even after escaping
=======
  # at this point the string replacement for an absolute windows path would
  # approximately be: C:\Users\hadley\...
  # this causes the PCRE regex compilation error, which wants
  # C:\\Users\hadley\...
  #thus this regex will replace, if it detects a windows absolute path delineated
  # by <Driveletter>:\ and replace it with <Driveletter>:\\ such that the regex
  # doesn't explode.
>>>>>>> master
  x <- gsub("(^\\D:)", "\\1\\\\", x)
  paste0("^", x, "$")
}
