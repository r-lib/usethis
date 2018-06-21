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

todo <- function(..., .envir = parent.frame()) {
  out <- glue(collapse(c(...), sep = ""), .envir = .envir)
  cat_line(bulletize(out, bullet = todo_bullet()))
}
done <- function(..., .envir = parent.frame()) {
  out <- glue(collapse(c(...), sep = ""), .envir = .envir)
  cat_line(bulletize(out, bullet = done_bullet()))
}

code_block <- function(..., copy = interactive()) {
  block <- paste0("  ", c(...), collapse = "\n")
  if (copy && clipr::clipr_available()) {
    clipr::write_clip(paste0(c(...), collapse = "\n"))
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

collapse <- function(x, sep = ", ") {
  glue::glue_collapse(x, sep = sep)
}
