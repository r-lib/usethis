context("utils")

test_that("check_is_dir() doesn't give false positive for trailing slash", {
  pwd <- sub("/$", "", getwd())
  expect_error_free(check_is_dir(paste0(pwd, "/")))
})

test_that("check_is_named_list() works", {
  l <- list(a = "a", b = 2, c = letters)
  expect_identical(l, check_is_named_list(l))

  expect_error(check_is_named_list(NULL), "must be a list")
  expect_error(check_is_named_list(c(a = "a", b = "b")), "must be a list")
  expect_error(check_is_named_list(list("a", b = 2)), "Names of .+ must be")
})

test_that("asciify() substitutes", {
  expect_identical(asciify("aB!d$F+_h"), "ab-d-f-_h")
})

test_that("slug() sets file extension, iff 'ext' not aleady the extension", {
  expect_equal(slug("abc", "R"), "abc.R")
  expect_equal(slug("abc.R", "R"), "abc.R")
  expect_equal(slug("abc.r", "R"), "abc.r")
  expect_equal(slug("abc.R", "txt"), "abc.txt")
})
