if (require(testthat)) {
  library({{{ name }}})
  test_check("{{{ name }}}")
} else {
  message("testthat not available.")
}
