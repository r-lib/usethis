can_overwrite <- function(path) {
  name <- basename(path)

  if (!file.exists(path)) {
    TRUE
  } else if (interactive() && !yesno("Overwrite `", name, "`?")) {
    TRUE
  } else {
    FALSE
  }
}

yesno <- function(...) {
  yeses <- c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely")
  nos <- c("No way", "Not yet", "I forget", "No", "Nope", "Uhhhh... Maybe?")

  cat(paste0(..., collapse = ""))
  qs <- c(sample(yeses, 1), sample(nos, 2))
  rand <- sample(length(qs))

  utils::menu(qs[rand]) != which(rand == 1)
}

is_dir <- function(x) file.info(x)$isdir

dots <- function(...) {
  eval(substitute(alist(...)))
}

slug <- function(x, ext) {
  stopifnot(is.character(x))

  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "-", x)

  paste0(x, ext)
}


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
    quoted <- paste0("'", new, "'", collapse = ", ")
    message("* Adding ", quoted, " to '", path, "'")
  }

  all <- union(lines, new_lines)
  write_utf8(full_path, all)
}

write_over <- function(base_path, path, contents) {
  stopifnot(is.character(contents), length(contents) == 1)

  full_path <- file.path(base_path, path)
  dir.create(dirname(full_path), showWarnings = FALSE)

  if (same_contents(full_path, contents))
    return(invisible(FALSE))

  if (!can_overwrite(full_path))
    stop("'", path, "' already exists.", call. = FALSE)

  message("* Writing '", path, "'")
  write_utf8(full_path, contents)
}

write_utf8 <- function(path, lines) {
  stopifnot(is.character(path))
  stopifnot(is.character(lines))

  con <- file(path, encoding = "utf-8")
  on.exit(close(con), add = TRUE)

  if (length(lines) > 1) {
    lines <- paste(lines, "\n", collapse = "")
  }
  cat(lines, file = con)

  invisible(TRUE)
}

same_contents <- function(path, contents) {
  if (!file.exists(path))
    return(FALSE)

  text_hash <- digest::digest(contents, serialize = FALSE)
  file_hash <- digest::digest(file = path)

  identical(text_hash, file_hash)
}

compact <- function(x) {
  is_empty <- vapply(x, function(x) length(x) == 0, logical(1))
  x[!is_empty]
}

"%||%" <- function(a, b) if (!is.null(a)) a else b
