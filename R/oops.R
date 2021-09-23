foo <- function() {
  on.exit(1 + 1)
  2 + 2
  path.expand("~/")
  3 + 3
}
