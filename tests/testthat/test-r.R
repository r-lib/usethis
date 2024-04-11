test_that("use_r() creates a .R file below R/", {
  create_local_package()
  use_r("foo")
  expect_proj_file("R/foo.R")
})

test_that("use_test() creates a test file", {
  create_local_package()
  use_test("foo", open = FALSE)
  expect_proj_file("tests", "testthat", "test-foo.R")
  use_test_helper("foo")
  expect_proj_file("tests", "testthat", "helper-foo.R")
  use_test_helper("")
  expect_proj_file("tests", "testthat", "helper.R")
})

test_that("can use use_test() and use_test_helper() in a project", {
  create_local_project()
  expect_no_error(use_test("foofy"))
  expect_no_error(use_test_helper("foofy"))
})

# helpers -----------------------------------------------------------------

test_that("compute_name() errors if no RStudio", {
  local_rstudio_available(FALSE)
  expect_snapshot(compute_name(), error = TRUE)
})

test_that("compute_name() sets extension if missing", {
  expect_equal(compute_name("foo"), "foo.R")
})

test_that("compute_name() validates its inputs", {
  expect_snapshot(error = TRUE, {
    compute_name("foo.c")
    compute_name("R/foo.c")
    compute_name(c("a", "b"))
    compute_name("")
    compute_name("****")
  })
})

test_that("compute_active_name() errors if no files open", {
  expect_snapshot(compute_active_name(NULL), error = TRUE)
})

test_that("compute_active_name() checks directory", {
  expect_snapshot(compute_active_name("foo/bar.R"), error = TRUE)
})

test_that("compute_active_name() standardises name", {
  dir <- create_local_project()

  expect_equal(
    compute_active_name(path(dir, "R/bar.R"), "c"),
    "bar.c"
  )
  expect_equal(
    compute_active_name(path(dir, "src/bar.cpp"), "R"),
    "bar.R"
  )
  expect_equal(
    compute_active_name(path(dir, "tests/testthat/test-bar.R"), "R"),
    "bar.R"
  )
  expect_equal(
    compute_active_name(path(dir, "tests/testthat/helper-bar.R"), "R"),
    "bar.R"
  )

  # https://github.com/r-lib/usethis/issues/1690
  expect_equal(
    compute_active_name(path(dir, "R/data.frame.R"), "R"),
    "data.frame.R"
  )
})

# https://github.com/r-lib/usethis/issues/1863
test_that("compute_name() accepts the declared extension", {
  expect_equal(compute_name("foo.cpp", ext = "cpp"), "foo.cpp")
})
