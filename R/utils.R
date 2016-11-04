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

slug <- function(x, ext) {
  stopifnot(is.character(x))

  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "-", x)

  paste0(x, ext)
}
