can_overwrite <- function(path) {
  if (!file.exists(path)) {
    return(TRUE)
  }

  if (interactive()) {
    yep("Overwrite pre-existing file ", value(basename(path)), "?")
  } else {
    FALSE
  }
}

## returns TRUE if user selects answer corresponding to `true_for`
## returns FALSE if user selects other answer or enters 0
## errors in non-interactive() session
## it is caller's responsibility to avoid that
ask_user <- function(...,
                     true_for = c("yes", "no")) {
  true_for <- match.arg(true_for)
  yes <- true_for == "yes"

  message <- paste0(..., collapse = "")
  if (!interactive()) {
    stop(
      "User input required in non-interactive session.\n",
      "Query: ", message, call. = FALSE
    )
  }

  yeses <- c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely")
  nos <- c("No way", "Not now", "Negative", "No", "Nope", "Absolutely not")

  qs <- c(sample(yeses, 1), sample(nos, 2))
  rand <- sample(length(qs))
  ret <- if(yes) rand == 1 else rand != 1

  cat(message)
  ret[utils::menu(qs[rand])]
}

nope <- function(...) ask_user(..., true_for = "no")
yep <- function(...) ask_user(..., true_for = "yes")

is_dir <- function(x) file.info(x)$isdir

check_is_dir <- function(x) {
  ## "checking it twice" for robustness to trailing slash issues on Windows
  if (!file.exists(x) && !dir.exists(x)) {
    stop("Directory does not exist:\n", value(x), call. = FALSE)
  }
  if (!is_dir(x)) {
    stop(value(x), " exists but is not a directory.", call. = FALSE)
  }
  invisible(x)
}

check_is_empty <- function(x) {
  files <- list.files(x)
  if (length(files) > 0) {
    stop(value(x), " exists and is not an empty directory", call. = FALSE)
  }
  invisible(x)
}

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
