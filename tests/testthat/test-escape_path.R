context("escape_path")

test_that("basic paths are replaced correctly", {
  expect_equal(
    escape_path("/home/example/file.R"),
    "^/home/example/file\\.R$"
  )
})

test_that("full windows paths re-escaped", {
  # calling normalizePath('.') will give a string path like such:
  expect_equal(
    escape_path("C:\\Hadley\\pkg\\docs"),
    "^C:\\\\Hadley\\pkg\\docs$"
  )
})

test_that("non-absolute windows paths not additional escaped", {
  expect_equal(
    escape_path("/usr/Hadley/pkg/docs"),
    "^/usr/Hadley/pkg/docs$"
  )
  expect_equal(
    escape_path("Hadley\\pkg\\docs"),
    "^Hadley\\pkg\\docs$"
  )
})
