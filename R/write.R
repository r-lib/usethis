write_union <- function(base_path, path, new_lines, quiet = FALSE) {
  stopifnot(is.character(new_lines))

  full_path <- file.path(base_path, path)
  if (file.exists(full_path)) {
    lines <- readLines(full_path, warn = FALSE)
  } else {
    lines <- character()
  }

  new <- setdiff(new_lines, lines)
  if (length(new) == 0)
    return(invisible(FALSE))

  if (!quiet) {
    quoted <- paste0(value(new), collapse = ", ")
    done("Adding ", quoted, " to ", value(path))
  }

  all <- union(lines, new_lines)
  write_utf8(full_path, all)
}

## `contents` is a character vector of prospective lines
write_over <- function(base_path, path, contents) {
  stopifnot(is.character(contents), length(contents) > 0)

  full_path <- file.path(base_path, path)
  dir.create(dirname(full_path), showWarnings = FALSE)

  if (same_contents(full_path, contents))
    return(invisible(FALSE))

  if (!can_overwrite(full_path))
    stop(value(path), " already exists.", call. = FALSE)

  done("Writing ", value(path))
  write_utf8(full_path, contents)
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
  if (!file.exists(path))
    return(FALSE)

  identical(readLines(path), contents)
}
