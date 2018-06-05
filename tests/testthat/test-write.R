context("write helpers")

test_that("same_contents() detects if contents are / are not same", {
  tmp <- tempfile()
  x <- letters[1:3]
  writeLines(x, con = tmp, sep = "\n")
  expect_true(same_contents(tmp, x))
  expect_false(same_contents(tmp, letters[4:6]))
})

test_that("write_union() writes a de novo file", {
  tmp <- file_temp()
  expect_false(file_exists(tmp))
  write_union(tmp, letters[1:3], quiet = TRUE)
  expect_identical(readLines(tmp), letters[1:3])
})

test_that("write_union() leaves file 'as is'", {
  tmp <- file_temp()
  writeLines(letters[1:3], tmp)
  before <- readLines(tmp)
  write_union(tmp, "b", quiet = TRUE)
  expect_identical(before, readLines(tmp))
})

test_that("write_union() adds lines", {
  tmp <- file_temp()
  writeLines(letters[1:3], tmp)
  write_union(tmp, letters[4:5], quiet = TRUE)
  expect_identical(readLines(tmp), letters[1:5])
})

test_that("write_over() writes a de novo file", {
  tmp <- file_temp()
  expect_false(file_exists(tmp))
  write_over(tmp, letters[1:3], quiet = TRUE)
  expect_identical(readLines(tmp), letters[1:3])
})

test_that("write_over() leaves file 'as is'", {
  tmp <- file_temp()
  writeLines(letters[1:3], tmp)
  before <- readLines(tmp)
  write_over(tmp, letters[1:3], quiet = TRUE)
  expect_identical(before, readLines(tmp))
})
