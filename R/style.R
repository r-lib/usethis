bullet <- function(lines, bullet) {
  lines <- paste0(bullet, " ", crayon::black(lines))
  message(lines)
}

todo_bullet <- function() crayon::red(clisymbols::symbol$bullet)

todo <- function(...) {
  bullet(paste0(...), bullet = todo_bullet())
}
done <- function(...) {
  bullet(paste0(...), bullet = crayon::green(clisymbols::symbol$tick))
}

code_block <- function(...) {
  block <- paste0("  ", c(...), collapse = "\n")
  message(crayon::make_style("darkgrey")(block))
}

cat_line <- function(...) {
  cat(..., sep = "")
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
  paste0(x, collapse = sep)
}
