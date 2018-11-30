# Glue wrappers -----------------------------------------------------------

ui_todo <- function(x, .envir = parent.frame()) {
  x <- glue(x, .envir = .envir)
  cat_bullet(x, crayon::red(clisymbols::symbol$bullet))
}

ui_done <- function(x, .envir = parent.frame()) {
  x <- glue(x, .envir = .envir)
  cat_bullet(x, crayon::red(crayon::green(clisymbols::symbol$tick)))
}

ui_code_block <- function(x, copy = interactive(), .envir = parent.frame()) {
  x <- glue(x, .envir = .envir)

  block <- indent(x, "  ")
  block <- crayon::make_style("darkgrey")(block)
  cat_line(block)

  if (copy && clipr::clipr_available()) {
    x <- crayon::strip_style(x)
    clipr::write_clip(x)
    cat_line("  [Copied to clipboard]")
  }
}

# Inline styling functions ------------------------------------------------

## use these inside ui_todo(), ui_done(), and ui_code_block()
## ^^ and let these functions handle any glue()ing ^^
field <- function(...) {
  x <- paste0(...)
  crayon::green(x)
}

value <- function(...) {
  x <- paste0(...)
  crayon::blue(encodeString(x, quote = "'"))
}

code <- function(...) {
  x <- paste0(...)
  crayon::make_style("darkgrey")(encodeString(x, quote = "`"))
}

unset <- function(...) {
  x <- paste0(...)
  crayon::make_style("lightgrey")(x)
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
  if (quiet)
    return(invisible())

  lines <- paste0(..., "\n")
  cat(lines, sep = "")
}
