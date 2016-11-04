
union_write <- function(path, new_lines) {
  if (file.exists(path)) {
    lines <- readLines(path, warn = FALSE)
  } else {
    lines <- character()
  }

  all <- union(lines, new_lines)
  writeLines(all, path)
}
