todo_bullet <- function() crayon::red(clisymbols::symbol$bullet)
done_bullet <- function() crayon::green(clisymbols::symbol$tick)

## generates one line
cat_line <- function(...) {
  cat(..., "\n", sep = "")
}

## generates one bulletized line
bulletize <- function(line, bullet = "*") {
  line <- paste0(bullet, " ", line)
}

## in the name of standardizing on glue
collapse <- function(x, sep = ", ", width = Inf, last = "") {
  glue::glue_collapse(x, sep = sep, width = Inf, last = last)
}

## glue into lines stored as character vector
glue_lines <- function(lines, .envir = parent.frame()) {
  unlist(lapply(lines, glue, .envir = .envir))
}

todo <- function(..., .envir = parent.frame()) {
  out <- glue(collapse(c(...), sep = ""), .envir = .envir)
  cat_line(bulletize(out, bullet = todo_bullet()))
}

done <- function(..., .envir = parent.frame()) {
  out <- glue(collapse(c(...), sep = ""), .envir = .envir)
  cat_line(bulletize(out, bullet = done_bullet()))
}

## each individual bit of `...` is destined to be a line
code_block <- function(..., copy = interactive(), .envir = parent.frame()) {
  lines <- glue_lines(c(...), .envir = .envir)
  block <- paste0("  ", lines, collapse = "\n")
  if (copy && clipr::clipr_available()) {
    clipr::write_clip(collapse(lines, sep = "\n"))
    message("Copying code to clipboard:")
  }
  cat_line(crayon::make_style("darkgrey")(block))
}


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
