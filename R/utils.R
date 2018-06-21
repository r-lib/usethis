can_overwrite <- function(path) {
  if (!file_exists(path)) {
    return(TRUE)
  }

  if (interactive()) {
    yep("Overwrite pre-existing file ", value(proj_rel_path(path)), "?")
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
    stop_glue(
      "User input required in non-interactive session.\n",
      "Query: {message}"
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

check_is_dir <- function(x) {
  ## "checking it twice" for robustness to trailing slash issues on Windows
  if (!file_exists(x) && !dir_exists(x)) {
    stop_glue("Directory does not exist:\n{value(x)}")
  }
  if (!is_dir(x)) {
    stop_glue("{value(x)} exists but is not a directory.")
  }
  invisible(x)
}

check_is_empty <- function(x) {
  files <- dir_ls(x)
  if (length(files) > 0) {
    stop_glue("{value(x)} exists and is not an empty directory.")
  }
  invisible(x)
}

check_is_named_list <- function(x, nm = deparse(substitute(x))) {
  if (!rlang::is_list(x)) {
    bad_class <- paste(class(x), collapse = "/")
    stop_glue("{code(nm)} must be a list, not {bad_class}.")
  }
  if (!rlang::is_dictionaryish(x)) {
    stop_glue(
      "Names of {code(nm)} must be non-missing, non-empty, and ",
      "non-duplicated."
    )
  }
  x
}

dots <- function(...) {
  eval(substitute(alist(...)))
}

asciify <- function(x) {
  stopifnot(is.character(x))

  x <- tolower(x)
  gsub("[^a-z0-9_-]+", "-", x)
}

slug <- function(x, ext) {
  x_base <- asciify(path_ext_remove(x))
  x_ext <- path_ext(x)
  ext <- if (identical(tolower(x_ext), tolower(ext))) x_ext else ext
  path_ext_set(x_base, ext)
}

compact <- function(x) {
  is_empty <- vapply(x, function(x) length(x) == 0, logical(1))
  x[!is_empty]
}

"%||%" <- function(a, b) if (!is.null(a)) a else b

check_installed <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop_glue("Package {value(pkg)} required. Please install before re-trying.")
  }
}

## mimimalist, type-specific purrr::pluck()'s
pluck_chr <- function(l, what) vapply(l, `[[`, character(1), what)

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}

interactive <- function() {
  base::interactive() && !is_testing()
}

is_string <- function(x) {
  length(x) == 1 && is.character(x)
}

stop_glue <- function(..., .sep = "", .envir = parent.frame()) {
  stop(usethis_error(glue(..., .sep = .sep, .envir = .envir)))
}

warning_glue <- function(..., .sep = "", .envir = parent.frame()) {
  warning(glue(..., .sep = .sep, .envir = .envir), call. = FALSE)
}

usethis_error <- function(msg) {
  structure(
    class = c("usethis_error", "error", "condition"),
    list(message = msg)
  )
}
