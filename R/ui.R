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
#' * inline styles: `ui_field()`, `ui_value()`, `ui_path()`, `ui_code()`,
#'   `ui_unset()`.
#'
#' The question functions [ui_yeah()] and [ui_nope()] have their own [help
#' page][ui-questions].
#'
#' @section Silencing output:
#' All UI output (apart from `ui_yeah()`/`ui_nope()` prompts) can be silenced
#' by setting `options(usethis.quiet = TRUE)`. Use `ui_silence()` to silence
#' selected actions.
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
ui_line <- function(x = character(), .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_inform(x)
}

#' @rdname ui
#' @export
ui_todo <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_bullet(x, crayon::red(cli::symbol$bullet))
}

#' @rdname ui
#' @export
ui_done <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_bullet(x, crayon::green(cli::symbol$tick))
}

#' @rdname ui
#' @export
ui_oops <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_bullet(x, crayon::red(cli::symbol$cross))
}

#' @rdname ui
#' @export
ui_info <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  ui_bullet(x, crayon::yellow(cli::symbol$info))
}

#' @param copy If `TRUE`, the session is interactive, and the clipr package
#'   is installed, will copy the code block to the clipboard.
#' @rdname ui
#' @export
ui_code_block <- function(x,
                          copy = rlang::is_interactive(),
                          .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  block <- indent(x, "  ")
  block <- crayon::silver(block)
  ui_inform(block)

  if (copy && clipr::clipr_available()) {
    x <- crayon::strip_style(x)
    clipr::write_clip(x)
    ui_inform("  [Copied to clipboard]")
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


# Silence -----------------------------------------------------------------

#' @rdname ui
#' @param code Code to execute with usual UI output silenced.
#' @export
ui_silence <- function(code) {
  withr::with_options(list(usethis.quiet = TRUE), code)
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

  if (!is_interactive()) {
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

  # TODO: should this be ui_inform()?
  rlang::inform(x)
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

#' @rdname ui
#' @export
ui_unset <- function(x = "unset") {
  stopifnot(length(x) == 1)
  x <- glue("<{x}>")
  x <- crayon::silver(x)
  x
}

# rlang::inform() wrappers -----------------------------------------------------

indent <- function(x, first = "  ", indent = first) {
  x <- gsub("\n", paste0("\n", indent), x)
  paste0(first, x)
}

ui_bullet <- function(x, bullet = cli::symbol$bullet) {
  bullet <- paste0(bullet, " ")
  x <- indent(x, bullet, "  ")
  ui_inform(x)
}

# All UI output must eventually go through ui_inform() so that it
# can be quieted with 'usethis.quiet' when needed.
ui_inform <- function(..., quiet = getOption("usethis.quiet", default = FALSE)) {
  if (!quiet) {
    inform(paste0(...))
  }

  invisible()
}

# Sitrep helpers ---------------------------------------------------------------

hd_line <- function(name) {
  ui_inform(crayon::bold(name))
}

kv_line <- function(key, value, .envir = parent.frame()) {
  value <- if (is.null(value)) ui_unset() else ui_value(value)
  key <- glue(key, .envir = .envir)
  ui_inform(glue("{cli::symbol$bullet} {key}: {value}"))
}
