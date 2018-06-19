#' Write into a file
#'
#' Writes lines to a file, taking the union of what's already there, if
#' anything, and some new lines. Note, there is no explicit promise about the
#' line order. This function is designed to modify simple config files like
#' `.Rbuildignore` and `.gitignore`.
#'
#' @param path Path to target file. It is created if it does not exist, but the
#'   parent directory must exist.
#' @param new_lines Character vector of lines to add, if not already present.
#' @param quiet Logical. Whether to message about what is happening.
#'
#' @return Logical indicating whether a write occurred, invisibly.
#' @export
#'
#' @examples
#' tmp <- tempfile()
#' write_union(tmp, letters[1:3])
#' readLines(tmp)
#' write_union(tmp, letters[1:5])
#' readLines(tmp)
#'
#' ## clean up
#' file.remove(tmp)
write_union <- function(path, new_lines, quiet = FALSE) {
  stopifnot(is.character(new_lines))
  path <- user_path_prep(path)

  if (file_exists(path)) {
    lines <- readLines(path, warn = FALSE)
  } else {
    lines <- character()
  }

  new <- setdiff(new_lines, lines)
  if (length(new) == 0) {
    return(invisible(FALSE))
  }

  if (!quiet) {
    done(glue("Adding {collapse(value(new))} to {value(proj_rel_path(path))}"))
  }

  all <- union(lines, new_lines)
  write_utf8(path, all)
}

## `contents` is a character vector of prospective lines
write_over <- function(path, contents, quiet = FALSE) {
  stopifnot(is.character(contents), length(contents) > 0)

  if (same_contents(path, contents)) {
    return(invisible(FALSE))
  }

  if (!can_overwrite(path)) {
    stop(value(path), " already exists.", call. = FALSE)
  }
  if (!quiet) {
    done("Writing ", value(proj_rel_path(path)))
  }

  write_utf8(path, contents)
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
