#' Write into or over a file
#'
#' Helpers to write into or over a new or pre-existing file. Designed mostly for
#' for internal use. File is written with UTF-8 encoding.
#'
#' @name write-this
#' @param path Path to target file. It is created if it does not exist, but the
#'   parent directory must exist.
#' @param lines Character vector of lines. For `write_union()`, these are lines
#'   to add to the target file, if not already present. For `write_over()`,
#'   these are the exact lines desired in the target file.
#' @param quiet Logical. Whether to message about what is happening.
#' @return Logical indicating whether a write occurred, invisibly.
#' @keywords internal
#'
#' @examples
#' \dontshow{.old_wd <- setwd(tempdir())}
#' write_union("a_file", letters[1:3])
#' readLines("a_file")
#' write_union("a_file", letters[1:5])
#' readLines("a_file")
#'
#' write_over("another_file", letters[1:3])
#' readLines("another_file")
#' write_over("another_file", letters[1:3])
#'
#' \dontrun{
#' ## will error if user isn't present to approve the overwrite
#' write_over("another_file", letters[3:1])
#' }
#'
#' ## clean up
#' file.remove("a_file", "another_file")
#' \dontshow{setwd(.old_wd)}
NULL

#' @describeIn write-this writes lines to a file, taking the union of what's
#'   already there, if anything, and some new lines. Note, there is no explicit
#'   promise about the line order. Designed to modify simple config files like
#'   `.Rbuildignore` and `.gitignore`.
#' @export
write_union <- function(path, lines, quiet = FALSE) {
  stopifnot(is.character(lines))
  path <- user_path_prep(path)

  if (file_exists(path)) {
    existing_lines <- readLines(path, warn = FALSE)
  } else {
    existing_lines <- character()
  }

  new <- setdiff(lines, existing_lines)
  if (length(new) == 0) {
    return(invisible(FALSE))
  }

  if (!quiet) {
    done("Adding {collapse(value(new))} to {value(proj_rel_path(path))}")
  }

  all <- union(lines, existing_lines)
  write_utf8(path, all)
}

#' @describeIn write-this writes a file with specific lines, creating it if
#'   necessary or overwriting existing, if proposed contents are not identical
#'   and user is available to give permission.
#' @param contents Character vector of lines.
#' @export
write_over <- function(path, lines, quiet = FALSE) {
  stopifnot(is.character(lines), length(lines) > 0)
  path <- user_path_prep(path)

  if (same_contents(path, lines)) {
    return(invisible(FALSE))
  }

  if (!can_overwrite(path)) {
    stop_glue("{value(path)} already exists.")
  }

  if (!quiet) {
    done("Writing {value(proj_rel_path(path))}")
  }

  write_utf8(path, lines)
}

write_utf8 <- function(path, lines) {
  stopifnot(is.character(path))
  stopifnot(is.character(lines))

  con <- file(path, encoding = "utf-8")
  on.exit(close(con), add = TRUE)

  if (length(lines) > 1) {
    lines <- paste0(lines, "\n", collapse = "")
  }
  cat(lines, file = con, sep = "")

  invisible(TRUE)
}

same_contents <- function(path, contents) {
  if (!file_exists(path)) {
    return(FALSE)
  }

  identical(readLines(path), contents)
}
