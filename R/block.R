block_append <- function(desc, value, path,
                         block_start = "# <<<",
                         block_end = "# >>>",
                         block_prefix = NULL,
                         block_suffix = NULL,
                         sort = FALSE) {
  if (!is.null(path) && file_exists(path)) {
    lines <- read_utf8(path)
    if (all(value %in% lines)) {
      return(FALSE)
    }

    block_lines <- block_find(lines, block_start, block_end)
  } else {
    block_lines <- NULL
  }

  if (is.null(block_lines)) {
    ui_todo("
      Copy and paste the following lines into {ui_path(path)}:")
    ui_code_block(c(block_prefix, block_start, value, block_end, block_suffix))
    return(FALSE)
  }

  ui_done("Adding {desc} to {ui_path(path)}")

  start <- block_lines[[1]]
  end <- block_lines[[2]]
  block <- lines[seq2(start, end)]

  new_lines <- union(block, value)
  if (sort) {
    new_lines <- sort(new_lines)
  }

  lines <- c(
    lines[seq2(1, start - 1L)],
    new_lines,
    lines[seq2(end + 1L, length(lines))]
  )
  write_utf8(path, lines)

  TRUE
}

block_replace <- function(desc, value, path,
                          block_start = "# <<<",
                          block_end = "# >>>") {
  if (!is.null(path) && file_exists(path)) {
    lines <- read_utf8(path)
    block_lines <- block_find(lines, block_start, block_end)
  } else {
    block_lines <- NULL
  }

  if (is.null(block_lines)) {
    ui_todo("Copy and paste the following lines into {ui_value(path)}:")
    ui_code_block(c(block_start, value, block_end))
    return(invisible(FALSE))
  }

  start <- block_lines[[1]]
  end <- block_lines[[2]]
  block <- lines[seq2(start, end)]

  if (identical(value, block)) {
    return(invisible(FALSE))
  }

  ui_done("Replacing {desc} in {ui_path(path)}")

  lines <- c(
    lines[seq2(1, start - 1L)],
    value,
    lines[seq2(end + 1L, length(lines))]
  )
  write_utf8(path, lines)
}


block_show <- function(path, block_start = "# <<<", block_end = "# >>>") {
  lines <- read_utf8(path)
  block <- block_find(lines, block_start, block_end)
  lines[seq2(block[[1]], block[[2]])]
}

block_find <- function(lines, block_start = "# <<<", block_end = "# >>>") {
  # No file
  if (is.null(lines)) {
    return(NULL)
  }

  start <- which(lines == block_start)
  end <- which(lines == block_end)

  # No block
  if (length(start) == 0 && length(end) == 0) {
    return(NULL)
  }

  if (!(length(start) == 1 && length(end) == 1 && start < end)) {
    ui_stop(
      "Invalid block specification.
      Must start with {ui_code(block_start)} and end with {ui_code(block_end)}"
    )
  }

  c(start + 1L, end - 1L)
}

block_create <- function(lines = character(), block_start = "# <<<", block_end = "# >>>") {
  c(block_start, unique(lines), block_end)
}
