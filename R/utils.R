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


write_union <- function(path, new_lines, quiet = FALSE) {
  stopifnot(is.character(new_lines))

  if (file.exists(path)) {
    lines <- readLines(path, warn = FALSE)
  } else {
    lines <- character()
  }

  new <- setdiff(new_lines, lines)
  if (!quiet && length(new) > 0) {
    quoted <- paste0("'", new, "'", collapse = ", ")
    message("* Adding ", quoted, " to '", basename(path), "'.")
  }

  all <- union(lines, new_lines)
  writeLines(all, path)
}

write_over <- function(contents, path) {
  stopifnot(is.character(contents), length(contents) == 1)

  if (same_contents(path, contents))
    return(FALSE)

  if (!can_overwrite(path))
    stop("'", path, "' already exists.", call. = FALSE)

  message("* Writing '", path, "'")
  cat(contents, file = path)
  TRUE
}

same_contents <- function(path, contents) {
  if (!file.exists(path))
    return(FALSE)

  text_hash <- digest::digest(contents, serialize = FALSE)
  file_hash <- digest::digest(file = path)

  identical(text_hash, file_hash)
}
