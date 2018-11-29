block_append <- function(desc, value, path, block_start, block_end) {
  if (!is.null(path) && file_exists(path)) {
    lines <- readLines(path)
    if (value %in% lines)
      return(FALSE)

    block_lines <- block_find(lines, block_start, block_end)
  } else {
    block_lines <- NULL
  }

  if (is.null(block_lines)) {
    todo("Copy and paste the following lines into {value(path)}:")
    code_block(c(
      block_start,
      value,
      block_end
    ))
    return(FALSE)
  }

  done("Adding {desc} to {value(proj_rel_path(path))}")

  start <- block_lines[[1]]
  end <- block_lines[[2]]
  block <- lines[seq2(start, end)]

  lines <- c(
    lines[seq2(1, start - 1L)],
    block,
    value,
    lines[seq2(end + 1L, length(lines))]
  )
  write_utf8(path, lines)

  TRUE
}

block_replace <- function(desc, value, path, block_start, block_end) {
  if (!is.null(path) && file_exists(path)) {
    lines <- readLines(path)
    block_lines <- block_find(lines, block_start, block_end)
  } else {
    block_lines <- NULL
  }

  if (is.null(block_lines)) {
    todo("Copy and paste the following lines into {value(path)}:")
    code_block(c(
      block_start,
      value,
      block_end
    ))
    return(invisible(FALSE))
  }

  start <- block_lines[[1]]
  end <- block_lines[[2]]
  block <- lines[seq2(start, end)]

  if (identical(value, block)) {
    return(invisible(FALSE))
  }

  done("Replacing {desc} in {value(proj_rel_path(path))}")

  lines <- c(
    lines[seq2(1, start - 1L)],
    value,
    lines[seq2(end + 1L, length(lines))]
  )
  write_utf8(path, lines)
}


block_show <- function(path, block_start, block_end) {
  lines <- readLines(path)
  block <- block_find(lines, block_start, block_end)
  lines[seq2(block[[1]], block[[2]])]
}

block_find <- function(lines, block_start, block_end) {
  # No file
  if (is.null(lines))
    return(NULL)

  start <- which(lines == block_start)
  end <- which(lines == block_end)

  # No block
  if (length(start) == 0 && length(end) == 0)
    return(NULL)

  if (!(length(start) == 1 && length(end) == 1 && start < end)) {
    stop_glue(
      "Invalid block specification.
      Must start with {code(block_start)} and end with {code(block_end)}"
    )
  }

  c(start + 1L, end - 1L)
}
