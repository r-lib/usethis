test_that("use_r() creates a .R file below R/", {
  create_local_package()
  use_r("foo")
  expect_proj_file("R/foo.R")
})

test_that("use_test() creates a test file", {
  create_local_package()
  use_test("foo", open = FALSE)
  expect_proj_file("tests", "testthat", "test-foo.R")
})

test_that("can use use_test() in a project", {
  create_local_project()
  expect_error(use_test("foofy"), NA)
})

# rename_files ------------------------------------------------------------

test_that("renames R and test and snapshot files", {
  create_local_package()
  git_init()

  use_r("foo", open = FALSE)
  rename_files("foo", "bar")
  expect_proj_file("R/bar.R")

  use_test("foo", open = FALSE)
  rename_files("foo", "bar")
  expect_proj_file("tests/testthat/test-bar.R")

  dir_create(proj_path("tests", "testthat", "_snaps"))
  write_utf8(proj_path("tests", "testthat", "_snaps", "foo.md"), "abc")
  rename_files("foo", "bar")
  expect_proj_file("tests/testthat/_snaps/bar.md")
})

test_that("strips context from test file", {
  create_local_package()
  git_init()

  use_testthat()
  write_utf8(
    proj_path("tests", "testthat", "test-foo.R"),
    c(
      "context('bar')",
      "",
      "a <- 1"
    )
  )

  rename_files("foo", "bar")
  lines <- read_utf8(proj_path("tests", "testthat", "test-bar.R"))
  expect_equal(lines, "a <- 1")
})

test_that("rename paths in test file", {
  create_local_package()
  git_init()

  use_testthat()
  write_utf8(proj_path("tests", "testthat", "test-foo.txt"), "10")
  write_utf8(proj_path("tests", "testthat", "test-foo.R"), "test-foo.txt")

  rename_files("foo", "bar")
  expect_proj_file("tests/testthat/test-bar.txt")
  lines <- read_utf8(proj_path("tests", "testthat", "test-bar.R"))
  expect_equal(lines, "test-bar.txt")
})

# helpers -----------------------------------------------------------------

test_that("check_file_name() requires single string", {
  expect_usethis_error(check_file_name(c("a", "b")), "single string")
})
