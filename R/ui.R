#' User interface
#'
#' These functions are used to construct the user interface of usethis. Use
#' them in your own package so that your `use_` functions work the same way
#' as usethis.
#'
#' The `ui_` functions can be broken down into four main categories:
#'
#' * block styles: `ui_line()`, `ui_done()`, `ui_todo()`.
#' * conditions: `ui_stop()`, `ui_warn()`.
#' * questions: `ui_yeah()`, `ui_nope()`.
#' * inline styles: `ui_field()`, `ui_value()`, `ui_path()`, `ui_code()`.
#'
#' @param x A character vector.
#'
#'   For block styles, conditions, and questions, each element of the
#'   vector becomes a line, and the result is processed by [glue::glue()].
#'   For inline styles, each element of the vector becomes an entry in a
#'   comma separated list.
#' @param .envir Used to ensure that [glue::glue()] gets the correct
#'   environment. For expert use only.
#' @return The block styles, conditions, and questions are called for their
#'   side-effect. The inline styles return a string.
#' @keywords internal
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
  cat_bullet(x, ui_orange(clisymbols::symbol$bullet))
}

#' @rdname ui
#' @export
ui_done <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  cat_bullet(x, ui_green(clisymbols::symbol$tick))
}

#' @rdname ui
#' @export
ui_oops <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  cat_bullet(x, ui_orange(clisymbols::symbol$cross))
}

#' @rdname ui
#' @export
ui_info <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)
  cat_bullet(x, ui_yellow(clisymbols::symbol$info))
}

#' @param copy If `TRUE`, the session is interactive, and the clipr package
#'   is installed, will copy the code block to the clipboard.
#' @rdname ui
#' @export
ui_code_block <- function(x, copy = interactive(), .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  block <- indent(x, "  ")
  block <- ui_grey(block)
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

#' @rdname ui
#' @export
ui_yeah <- function(x, .envir = parent.frame()) {
  x <- glue_collapse(x, "\n")
  x <- glue(x, .envir = .envir)

  if (!interactive()) {
    ui_stop(c(
      "User input required, but session is not interactive.",
      "Query: {x}"
    ))
  }

  ayes <- c("Yes", "Definitely", "For sure", "Yup", "Yeah", "I agree", "Absolutely")
  nays <- c("No way", "Not now", "Negative", "No", "Nope", "Absolutely not")

  qs <- c(sample(ayes, 1), sample(nays, 2))
  ord <- sample(length(qs))

  cat_line(x)
  out <- utils::menu(qs[ord])
  out != 0L && (ord == 1)[[out]]
}

#' @rdname ui
#' @export
ui_nope <- function(x, .envir = parent.frame()) {
  !ui_yeah(x, .envir = .envir)
}

# Inline styles -----------------------------------------------------------

#' @rdname ui
#' @export
ui_field <- function(x) {
  x <- ui_green(x)
  x <- glue_collapse(x, sep = ", ")
  x
}

#' @rdname ui
#' @export
ui_value <- function(x) {
  if (is.character(x) && !crayon::has_color()) {
    x <- encodeString(x, quote = "'")
  }
  x <- ui_blue(x)
  x <- glue_collapse(x, sep = ", ")
  x
}

#' @rdname ui
#' @export
#' @param base If specified, paths will be displayed relative to this path.
ui_path <- function(x, base = NULL) {
  is_directory <- is_dir(x)
  if (is.null(base)) {
    x <- proj_rel_path(x)
  } else if (!identical(base, NA)) {
    x <- path_rel(x, base)
  }

  x <- paste0(x, ifelse(is_directory, "/", ""))
  x <- ui_value(x)
  x
}

#' @rdname ui
#' @export
ui_code <- function(x) {
  x <- encodeString(x, quote = "`")
  x <- ui_grey(x)
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

  lines <- paste0(..., "\n")
  cat(lines, sep = "")
}

# Sitrep helpers ---------------------------------------------------------------

hd_line <- function(name) {
  cat_line(crayon::bold(name))
}

kv_line <- function(key, value) {
  value <- value %||% "<unset>"
  if (length(value) == 1 && grepl("^<.*>$", value)) {
    value <- ui_grey(value)
  } else {
    value <- ui_value(value)
  }
  cat_line("* ", key, ": ", value)
}

# Color helpers ---------------------------------------------------------------
solarized_hex<- c(
  base03 = "#002b36", base02 = "#073642",  base01 = "#586e75",
  base00 = "#657b83",  base0 = "#839496",   base1 = "#93a1a1",
  base2  = "#eee8d5",  base3 = "#fdf6e3",  yellow = "#b58900",
  orange = "#cb4b16",    red = "#dc322f", magenta = "#d33682",
  violet = "#6c71c4",   blue = "#268bd2",    cyan = "#2aa198",
   green = "#859900"
)

solarized_xterm <- c(
  base03 = "#1c1c1c", base02 = "#262626",  base01 = "#585858",
  base00 = "#626262",  base0 = "#808080",   base1 = "#8a8a8a",
   base2 = "#e4e4e4",  base3 = "#ffffd7",  yellow = "#af8700",
  orange = "#d75f00",    red = "#d70000", magenta = "#af005f",
  violet = "#5f5faf",   blue = "#0087ff",    cyan = "#00afaf",
   green = "#5f8700"
)

ui_yellow  <- crayon::make_style(solarized_hex["yellow"])
ui_orange  <- crayon::make_style(solarized_hex["orange"])
ui_red     <- crayon::make_style(solarized_hex["red"])
ui_magenta <- crayon::make_style(solarized_hex["magenta"])
ui_violet  <- crayon::make_style(solarized_hex["violet"])
ui_blue    <- crayon::make_style(solarized_hex["blue"])
ui_cyan    <- crayon::make_style(solarized_hex["cyan"])
ui_green   <- crayon::make_style(solarized_hex["green"])

ui_grey    <- crayon::make_style(solarized_xterm["base0"])

ui_base03 <- crayon::make_style(solarized_xterm["base03"])
ui_base02 <- crayon::make_style(solarized_xterm["base02"])
ui_base01 <- crayon::make_style(solarized_xterm["base01"])
ui_base00 <- crayon::make_style(solarized_xterm["base00"])
ui_base0  <- crayon::make_style(solarized_xterm["base0"])
ui_base1  <- crayon::make_style(solarized_xterm["base1"])
ui_base2  <- crayon::make_style(solarized_xterm["base2"])
ui_base3  <- crayon::make_style(solarized_xterm["base3"])
