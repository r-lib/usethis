#' User interface
#'
#' @description
#' These functions are used to construct the user interface of usethis. Use
#' them in your own package so that your `use_` functions work the same way
#' as usethis.
#'
#' The `ui_` functions can be broken down into four main categories:
#'
#' * block styles: `ui_line()`, `ui_done()`, `ui_todo()`, `ui_oops()`,
#'   `ui_info()`.
#' * conditions: `ui_stop()`, `ui_warn()`.
#' * questions: [ui_yeah()], [ui_nope()].
#' * inline styles: `ui_field()`, `ui_value()`, `ui_path()`, `ui_code()`.
#'
#' The question functions [ui_yeah()] and [ui_nope()] have their own [help
#' page][ui-questions].
#'
#' @param x A character vector.
#'
#'   For block styles, conditions, and questions, each element of the
#'   vector becomes a line, and the result is processed by [glue::glue()].
#'   For inline styles, each element of the vector becomes an entry in a
#'   comma separated list.
#' @param .envir Used to ensure that [glue::glue()] gets the correct
#'   environment. For expert use only.
#'
#' @return The block styles, conditions, and questions are called for their
#'   side-effect. The inline styles return a string.
#' @keywords internal
#' @family user interface functions
#' @name ui
#' @examples
#' new_val <- "oxnard"
#' ui_done("{ui_field('name')} set to {ui_value(new_val)}")
#' ui_todo("Redocument with {ui_code('devtools::document()')}")
#'
#' ui_code_block(c(
#'   "Line 1",
#'   "Line 2",
#'   "Line 3"
#' ))
NULL

# Block styles ------------------------------------------------------------

#' @rdname ui
#' @export
ui_line <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  cat_line(x)
}

#' @rdname ui
#' @export
ui_todo <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  cat_bullet(x, crayon::red(clisymbols::symbol$bullet))
}

#' @rdname ui
#' @export
ui_done <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  cat_bullet(x, crayon::green(clisymbols::symbol$tick))
}

#' @rdname ui
#' @export
ui_oops <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  cat_bullet(x, crayon::red(clisymbols::symbol$cross))
}

#' @rdname ui
#' @export
ui_info <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  cat_bullet(x, crayon::yellow(clisymbols::symbol$info))
}

#' @param copy If `TRUE`, the session is interactive, and the clipr package
#'   is installed, will copy the code block to the clipboard.
#' @rdname ui
#' @export
ui_code_block <- function(x, copy = interactive(), .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  block <- indent(x, "  ")
  block <- crayon::silver(block)
  cat_line(block)

  if (copy && clipr::clipr_available()) {
    x <- crayon::strip_style(x)
    clipr::write_clip(x)
    cat_line("  [Copied to clipboard]")
  }
}

# Conditions --------------------------------------------------------------

#' @rdname ui
#' @export
ui_stop <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  cnd <- structure(
    class = c("usethis_error", "error", "condition"),
    list(message = x)
  )

  stop(cnd)
}

#' @rdname ui
#' @export
ui_warn <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  warning(x, call. = FALSE, immediate. = TRUE)
}

# Questions ---------------------------------------------------------------

#' User interface - Questions
#'
#' These functions are used to interact with the user by posing a simple yes or
#' no question. For details on the other `ui_*()` functions, see the [ui] help
#' page.
#'
#' @inheritParams ui
#' @param yes A character vector of "yes" strings, which are randomly sampled to
#'   populate the menu.
#' @param no A character vector of "no" strings, which are randomly sampled to
#'   populate the menu.
#' @param n_yes An integer. The number of "yes" strings to include.
#' @param n_no An integer. The number of "no" strings to include.
#' @param shuffle A logical. Should the order of the menu options be randomly
#'   shuffled?
#'
#' @return A logical. `ui_yeah()` returns `TRUE` when the user selects a "yes"
#'   option and `FALSE` otherwise, i.e. when user selects a "no" option or
#'   refuses to make a selection (cancels). `ui_nope()` is the logical opposite
#'   of `ui_yeah()`.
#' @name ui-questions
#' @keywords internal
#' @family user interface functions
#' @examples
#' \dontrun{
#' ui_yeah("Do you like R?")
#' ui_nope("Have you tried turning it off and on again?", n_yes = 1, n_no = 1)
#' ui_yeah("Are you sure its plugged in?", yes = "Yes", no = "No", shuffle = FALSE)
#' }
NULL

#' @rdname ui-questions
#' @export
ui_yeah <- function(x,
                    yes = c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely"),
                    no = c("No way", "Not now", "Negative", "No", "Nope", "Absolutely not"),
                    n_yes = 1, n_no = 2, shuffle = TRUE,
                    .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  if (!interactive()) {
    ui_stop(c(
      "User input required, but session is not interactive.",
      "Query: {x}"
    ))
  }

  n_yes <- min(n_yes, length(yes))
  n_no <- min(n_no, length(no))

  qs <- c(sample(yes, n_yes), sample(no, n_no))

  if (shuffle) {
    qs <- sample(qs)
  }

  cat_line(x)
  out <- utils::menu(qs)
  out != 0L && qs[[out]] %in% yes
}

#' @rdname ui-questions
#' @export
ui_nope <- function(x,
                    yes = c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely"),
                    no = c("No way", "Not now", "Negative", "No", "Nope", "Absolutely not"),
                    n_yes = 1, n_no = 2, shuffle = TRUE,
                    .envir = parent.frame()) {
  # TODO(jennybc): is this correct in the case of no selection / cancelling?
  !ui_yeah(
    x = x, yes = yes, no = no,
    n_yes = n_yes, n_no = n_no,
    shuffle = shuffle,
    .envir = .envir
  )
}

# Inline styles -----------------------------------------------------------

#' @rdname ui
#' @export
ui_field <- function(x) {
  x <- crayon::green(x)
  x <- glue_collapse(x, sep = ", ")
  x
}

#' @rdname ui
#' @export
ui_value <- function(x) {
  if (is.character(x)) {
    x <- encodeString(x, quote = "'")
  }
  x <- crayon::blue(x)
  x <- glue_collapse(x, sep = ", ")
  x
}

#' @rdname ui
#' @export
#' @param base If specified, paths will be displayed relative to this path.
ui_path <- function(x, base = NULL) {
  is_directory <- is_dir(x) | grepl("/$", x)
  if (is.null(base)) {
    x <- proj_rel_path(x)
  } else if (!identical(base, NA)) {
    x <- path_rel(x, base)
  }

  # rationalize trailing slashes
  x <- path_tidy(x)
  x <- ifelse(is_directory, paste0(x, "/"), x)

  ui_value(x)
}

#' @rdname ui
#' @export
ui_code <- function(x) {
  x <- encodeString(x, quote = "`")
  x <- crayon::silver(x)
  x <- glue_collapse(x, sep = ", ")
  x
}

# Cat wrappers ---------------------------------------------------------------

cat_bullet <- function(x, bullet) {
  bullet <- paste0(bullet, " ")
  x <- indent(x, bullet, "  ")
  cat_line(x)
}

# All UI output must eventually go through cat_line() so that it
# can be quieted with 'usethis.quiet' when needed.
cat_line <- function(..., quiet = getOption("usethis.quiet", default = FALSE)) {
  if (quiet) {
    return(invisible())
  }

  lines <- paste0(...)
  # TODO: remove this once I can bump minimum version of rlang to get
  # https://github.com/r-lib/rlang/commit/c726908afcf1857fd98378f403d3d194ac9753bf
  # presumably rlang 0.4.3
  if (length(lines) < 1) {
    lines <- ""
  }
  rlang::inform(lines)

  invisible()
}

# Sitrep helpers ---------------------------------------------------------------

hd_line <- function(name) {
  cat_line(crayon::bold(name))
}

kv_line <- function(key, value) {
  if (is.null(value)) {
    value <- crayon::silver("<unset>")
  } else {
    value <- ui_value(value)
  }
  cat_line("* ", key, ": ", value)
}
