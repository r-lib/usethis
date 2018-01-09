can_overwrite <- function(path) {
  if (!file.exists(path)) {
    return(TRUE)
  }

  if (interactive()) {
    !nope("Overwrite pre-existing file ", value(basename(path)), "?")
  } else {
    FALSE
  }
}

## FALSE: user selected the "yes"
## TRUE: user did anything else: selected one of the "no's" or selected nothing,
##   i.e. entered 0
nope <- function(...) {
  message <- paste0(..., collapse = "")
  if (!interactive()) {
    stop(
      "User input required in non-interactive session.\n",
      "Query: ", message, call. = FALSE
    )
  }
  yeses <- c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely")
  nos <- c("No way", "Not yet", "I forget", "No", "Nope", "Hell no")

  cat(message)
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
  x <- gsub("[^a-z0-9_]+", "-", x)

  paste0(x, ext)
}

compact <- function(x) {
  is_empty <- vapply(x, function(x) length(x) == 0, logical(1))
  x[!is_empty]
}

"%||%" <- function(a, b) if (!is.null(a)) a else b

check_installed <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      "Package ", value(pkg), " required. Please install before re-trying",
      call. = FALSE
    )
  }
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

interactive <- function() {
  base::interactive() && !is_testing()
}

is_string <- function(x) {
  length(x) == 1 && is.character(x)
}
