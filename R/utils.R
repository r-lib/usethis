union_write <- function(path, new_lines, quiet = FALSE) {
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

  menu(qs[rand]) != which(rand == 1)
}

is_dir <- function(x) file.info(x)$isdir

dots <- function(...) {
  eval(substitute(alist(...)))
}
