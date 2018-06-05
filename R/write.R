write_union <- function(path, new_lines, quiet = FALSE) {
  stopifnot(is.character(new_lines))

  if (file.exists(path)) {
    lines <- readLines(path, warn = FALSE)
  } else {
    lines <- character()
  }

  new <- setdiff(new_lines, lines)
  if (length(new) == 0) {
    return(invisible(FALSE))
  }

  if (!quiet) {
    done(glue("Adding {collapse(value(new))} to {value(path)}"))
  }

  all <- union(lines, new_lines)
  write_utf8(path, all)
}

## `contents` is a character vector of prospective lines
write_over <- function(path, contents) {
  stopifnot(is.character(contents), length(contents) > 0)

  if (same_contents(path, contents)) {
    return(invisible(FALSE))
  }

  if (!can_overwrite(path)) {
    stop(value(path), " already exists.", call. = FALSE)
  }

  done("Writing ", value(path))
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
  if (!file.exists(path)) {
    return(FALSE)
  }

  identical(readLines(path), contents)
}
