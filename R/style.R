# Helpers --------------------------------------------------------------------

## anticipates usage where the `...` bits make up one line
cat_line <- function(...) {
  cat(..., "\n", sep = "")
}

todo_bullet <- function() crayon::red(clisymbols::symbol$bullet)
done_bullet <- function() crayon::green(clisymbols::symbol$tick)

## adds a leading bullet
bulletize <- function(line, bullet = "*") {
  paste0(bullet, " ", line)
}

collapse <- function(x, sep = ", ", width = Inf, last = "") {
  glue::glue_collapse(x, sep = sep, width = Inf, last = last)
}

## glue into lines stored as character vector
glue_lines <- function(lines, .envir = parent.frame()) {
  unlist(lapply(lines, glue, .envir = .envir))
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


# Function designed for several lines -------------------------------------

## ALERT: each individual bit of `...` is destined to be a line
code_block <- function(..., copy = interactive(), .envir = parent.frame()) {
  lines <- glue_lines(c(...), .envir = .envir)
  block <- paste0("  ", lines, collapse = "\n")
  if (copy && clipr::clipr_available()) {
    clipr::write_clip(collapse(lines, sep = "\n"))
    message("Copying code to clipboard:")
  }
  cat_line(crayon::make_style("darkgrey")(block))
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
