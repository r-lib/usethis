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

test_that("renames src/ files", {
  create_local_package()
  git_init()

  use_src()
  file_create(proj_path("src/foo.c"))
  file_create(proj_path("src/foo.h"))

  withr::local_options(list(usethis.quiet = FALSE))
  expect_snapshot({
    rename_files("foo", "bar")
  })

  expect_proj_file("src/bar.c")
  expect_proj_file("src/bar.h")
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

test_that("compute_name() errors if no RStudio", {
  mockr::local_mock(rstudio_available = function(...) FALSE)
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

  # https://github.com/r-lib/usethis/issues/1690
  expect_equal(
    compute_active_name(path(dir, "R/data.frame.R"), "R"),
    "data.frame.R"
  )

})
