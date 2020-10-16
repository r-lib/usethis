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
  expect_identical(read_utf8(tmp), letters[1:3])
})

test_that("write_union() leaves file 'as is'", {
  tmp <- file_temp()
  writeLines(letters[1:3], tmp)
  before <- read_utf8(tmp)
  write_union(tmp, "b", quiet = TRUE)
  expect_identical(before, read_utf8(tmp))
})

test_that("write_union() adds lines", {
  tmp <- file_temp()
  writeLines(letters[1:3], tmp)
  write_union(tmp, letters[4:5], quiet = TRUE)
  expect_setequal(read_utf8(tmp), letters[1:5])
})

# https://github.com/r-lib/usethis/issues/526
test_that("write_union() doesn't remove duplicated lines in the input", {
  tmp <- file_temp()
  before <- rep(letters[1:2], 3)
  add_me <- c("z", "a", "c", "a", "b")
  writeLines(before, tmp)
  expect_identical(before, read_utf8(tmp))
  write_union(tmp, add_me, quiet = TRUE)
  expect_identical(read_utf8(tmp), c(before, c("z", "c")))
})

test_that("write_over() writes a de novo file", {
  tmp <- file_temp()
  expect_false(file_exists(tmp))
  write_over(tmp, letters[1:3], quiet = TRUE)
  expect_identical(read_utf8(tmp), letters[1:3])
})

test_that("write_over() leaves file 'as is'", {
  tmp <- file_temp()
  writeLines(letters[1:3], tmp)
  before <- read_utf8(tmp)
  write_over(tmp, letters[1:3], quiet = TRUE)
  expect_identical(before, read_utf8(tmp))
})

# https://github.com/r-lib/usethis/issues/514
test_that("write_utf8() always produces a trailing newline", {
  path <- file_temp()
  write_utf8(path, "x", line_ending = "\n")
  expect_equal(readChar(path, 2), "x\n")
})

test_that("write_utf8() can append text when requested", {
  path <- file_temp()
  write_utf8(path, "x", line_ending = "\n")
  write_utf8(path, "x", line_ending = "\n", append = TRUE)

  expect_equal(readChar(path, 4), "x\nx\n")
})

test_that("write_utf8() respects line ending", {
  path <- file_temp()

  write_utf8(path, "x", line_ending = "\n")
  expect_equal(detect_line_ending(path), "\n")

  write_utf8(path, "x", line_ending = "\r\n")
  expect_equal(detect_line_ending(path), "\r\n")
})

test_that("write_utf8() can operate outside of a project", {
  tmpdir <- file_temp()
  dir_create(tmpdir)
  # doing this "by hand" vs. via withr because Windows appears to be unwilling
  # to delete current working directory
  oldwd <- setwd(tmpdir)
  on.exit({
    setwd(oldwd)
    dir_delete(tmpdir)
  })

  local_project(NULL)

  expect_false(proj_active())
  expect_error_free(write_utf8(path = "foo", letters[1:3]))
})
