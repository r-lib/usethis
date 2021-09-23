foo <- function() {
  path.expand("~/")
  if (interactive()) {
    2 + 2
  }
  on.exit(1 + 1)
  3 + 3
}
