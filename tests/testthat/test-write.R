context("write helpers")

test_that("write_union() does not activate a project", {
  tmpdir <- file_temp(pattern = "write-tests")
  on.exit(dir_delete(tmpdir))
  dir_create(tmpdir)
  file_create(path(tmpdir, ".here"))

  expect_true(possibly_in_proj(tmpdir))
  expect_false(is_in_proj(tmpdir))
  ## don't use `quiet = TRUE` because prevents what I want to test
  write_union(path(tmpdir, "abc"), lines = letters[1:3])
  expect_false(is_in_proj(tmpdir))
})

test_that("same_contents() detects if contents are / are not same", {
  tmp <- file_temp()
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
  expect_setequal(readLines(tmp), letters[1:5])
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
