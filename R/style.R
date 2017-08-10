bullet <- function(lines, bullet) {
  lines <- paste0(bullet, " ", crayon::black(lines))
  cat_line(paste0(lines, "\n"))
}

todo_bullet <- function() crayon::red(clisymbols::symbol$bullet)

todo <- function(...) {
  bullet(paste0(...), bullet = todo_bullet())
}
done <- function(...) {
  bullet(paste0(...), bullet = crayon::green(clisymbols::symbol$tick))
}

code_block <- function(...) {
  lines <- c(...)
  block <- paste0("  ", lines, "\n", collapse = "")
  cat_line(crayon::make_style("darkgrey")(block))
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

collapse <- function(x, sep = ", ") {
  paste0(x, collapse = sep)
}
