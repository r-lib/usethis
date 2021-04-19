# test that write_utf8() does not alter active project and
# does not consult active project for line ending
test_that("write_utf8(): no active project, write path outside project", {
  local_project(NULL)
  expect_false(proj_active())
  dir <- withr::local_tempdir(pattern = "write-utf8-nonproject")
  expect_false(possibly_in_proj(dir))

  write_utf8(path(dir, "letters_LF"), letters[1:2], line_ending = "\n")
  expect_equal(
    readBin(path(dir, "letters_LF"), what = "raw", n = 3),
    charToRaw("a\nb")
  )
  write_utf8(path(dir, "letters_CRLF"), letters[1:2], line_ending = "\r\n")
  expect_equal(
    readBin(path(dir, "letters_CRLF"), what = "raw", n = 3),
    charToRaw("a\r\n")
  )

  expect_false(proj_active())
})

test_that("write_utf8(): no active project, write to path inside a project", {
  local_project(NULL)
  expect_false(proj_active())
  dir <- withr::local_tempdir(pattern = "write-utf8-in-a-project")
  file_create(path(dir, ".here"))
  expect_true(possibly_in_proj(dir))

  with_project(dir, use_rstudio(line_ending = "posix"))
  write_utf8(path(dir, "letters"), letters[1:2])
  expect_equal(
    readBin(path(dir, "letters"), what = "raw", n = 3),
    charToRaw("a\nb")
  )
  file_delete(path(dir, paste0(path_file(dir), ".Rproj")))

  with_project(dir, use_rstudio(line_ending = "windows"))
  write_utf8(path(dir, "letters"), letters[1:2])
  expect_equal(
    readBin(path(dir, "letters"), what = "raw", n = 3),
    charToRaw("a\r\n")
  )

  expect_false(proj_active())
})

test_that("write_utf8(): in an active project, write path outside project", {
  proj <- create_local_project(rstudio = TRUE)
  expect_true(proj_active())
  dir <- withr::local_tempdir(pattern = "write-utf8-nonproject")
  expect_false(possibly_in_proj(dir))

  write_utf8(path(dir, "letters_LF"), letters[1:2], line_ending = "\n")
  expect_equal(
    readBin(path(dir, "letters_LF"), what = "raw", n = 3),
    charToRaw("a\nb")
  )
  write_utf8(path(dir, "letters_CRLF"), letters[1:2], line_ending = "\r\n")
  expect_equal(
    readBin(path(dir, "letters_CRLF"), what = "raw", n = 3),
    charToRaw("a\r\n")
  )

  expect_equal(proj_get(), proj)
})

test_that("write_utf8(): in an active project, write path in other project", {
  proj <- create_local_project(rstudio = TRUE)
  expect_true(proj_active())
  dir <- withr::local_tempdir(pattern = "write-utf8-in-a-project")
  file_create(path(dir, ".here"))
  expect_true(possibly_in_proj(dir))

  with_project(dir, use_rstudio(line_ending = "posix"))
  write_utf8(path(dir, "letters"), letters[1:2])
  expect_equal(
    readBin(path(dir, "letters"), what = "raw", n = 3),
    charToRaw("a\nb")
  )
  file_delete(path(dir, paste0(path_file(dir), ".Rproj")))

  with_project(dir, use_rstudio(line_ending = "windows"))
  write_utf8(path(dir, "letters"), letters[1:2])
  expect_equal(
    readBin(path(dir, "letters"), what = "raw", n = 3),
    charToRaw("a\r\n")
  )

  expect_equal(proj_get(), proj)
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

# TODO: explore more edge cases re: active project on both sides
test_that("write_utf8() can operate outside of a project", {
  dir <- withr::local_tempdir(pattern = "write-utf8-test")
  withr::local_dir(dir)
  local_project(NULL)

  expect_false(proj_active())
  expect_error_free(write_utf8(path = "foo", letters[1:3]))
})

# https://github.com/r-lib/usethis/issues/514
test_that("write_utf8() always produces a trailing newline", {
  path <- file_temp()
  write_utf8(path, "x", line_ending = "\n")
  expect_equal(readChar(path, 2), "x\n")
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

test_that("same_contents() detects if contents are / are not same", {
  tmp <- file_temp()
  x <- letters[1:3]
  writeLines(x, con = tmp, sep = "\n")
  expect_true(same_contents(tmp, x))
  expect_false(same_contents(tmp, letters[4:6]))
})

test_that("write_over() writes a de novo file", {
  tmp <- file_temp()
  expect_false(file_exists(tmp))
  write_over(tmp, letters[1:3], quiet = TRUE)
  expect_identical(read_utf8(tmp), letters[1:3])
})

test_that("write_over() leaves file 'as is' (outside of a project)", {
  local_interactive(FALSE)
  tmp <- withr::local_file(file_temp())

  writeLines(letters[1:3], tmp)

  before <- read_utf8(tmp)
  write_over(tmp, letters[4:6], quiet = TRUE)
  expect_identical(read_utf8(tmp), before)

  # usethis.overwrite shouldn't matter for a file outside of a project
  withr::with_options(
    list(usethis.overwrite = TRUE),
    {
      write_over(tmp, letters[4:6], quiet = TRUE)
      expect_identical(read_utf8(tmp), before)
    }
  )
})

test_that("write_over() works in active project", {
  local_interactive(FALSE)
  create_local_project()

  tmp <- proj_path("foo.txt")
  writeLines(letters[1:3], tmp)

  before <- read_utf8(tmp)
  write_over(tmp, letters[4:6], quiet = TRUE)
  expect_identical(read_utf8(tmp), before)

  use_git()
  withr::with_options(
    list(usethis.overwrite = TRUE),
    {
      write_over(tmp, letters[4:6], quiet = TRUE)
      expect_identical(read_utf8(tmp), letters[4:6])
    }
  )
})

test_that("write_over() works for a file in a project that is not active", {
  local_interactive(FALSE)
  owd <- getwd()
  proj <- create_local_project()
  use_git()

  tmp <- proj_path("foo.txt")
  writeLines(letters[1:3], tmp)

  withr::local_dir(owd)
  local_project(NULL)
  expect_false(proj_active())

  tmp <- path(proj, "foo.txt")
  before <- read_utf8(tmp)
  write_over(tmp, letters[4:6], quiet = TRUE)
  expect_identical(read_utf8(tmp), before)

  withr::with_options(
    list(usethis.overwrite = TRUE),
    {
      write_over(tmp, letters[4:6], quiet = TRUE)
      expect_identical(read_utf8(tmp), letters[4:6])
    }
  )
  expect_false(proj_active())
})
