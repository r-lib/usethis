# Helpers --------------------------------------------------------------------

## anticipates usage where the `...` bits make up one line
##
## 'usethis.quiet' is an undocumented option; anticipated usage:
##   * eliminate `capture_output()` calls in usethis tests
##   * other packages, e.g., devtools can call usethis functions quietly
cat_line <- function(..., quiet = getOption("usethis.quiet", default = FALSE)) {
  if (quiet) return(invisible())
  cat(..., "\n", sep = "")
}

todo_bullet <- function() crayon::red(clisymbols::symbol$bullet)
done_bullet <- function() crayon::green(clisymbols::symbol$tick)

## adds a leading bullet
bulletize <- function(line, bullet = "*") {
  paste0(bullet, " ", line)
}

# Functions designed for a single line ----------------------------------------
todo <- function(..., .envir = parent.frame()) {
  out <- glue(..., .envir = .envir)
  cat_line(bulletize(out, bullet = todo_bullet()))
}

done <- function(..., .envir = parent.frame()) {
  out <- glue(..., .envir = .envir)
  cat_line(bulletize(out, bullet = done_bullet()))
}

ui_code_block <- function(code, copy = interactive(), .envir = parent.frame()) {
  code <- glue(code, .envir = .envir)

  block <- indent(code, "  ")
  block <- crayon::make_style("darkgrey")(block)
  cat_line(block)

  if (copy && clipr::clipr_available()) {
    code <- crayon::strip_style(code)
    clipr::write_clip(code)
    cat_line("  [Copied to clipboard]")
  }
}

indent <- function(x, indent = "  ") {
  x <- gsub("\n", paste0("\n", indent), x)
  paste0(indent, x)
}

# Inline styling functions ------------------------------------------------

## use these inside todo(), done(), and code_block()
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
