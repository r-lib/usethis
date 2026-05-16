test_that("checks uncommitted files", {
  create_local_package()
  expect_usethis_error(rename_files("foo", "bar"))

  git_init()
  use_r("foo", open = FALSE)
  expect_usethis_error(
    rename_files("foo", "bar"),
    "Uncommitted changes"
  )
})

test_that("renames R and test and snapshot files", {
  create_local_package()
  local_mocked_bindings(
    challenge_uncommitted_changes = function(...) invisible()
  )
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
  local_mocked_bindings(
    challenge_uncommitted_changes = function(...) invisible()
  )
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
  local_mocked_bindings(
    challenge_uncommitted_changes = function(...) invisible()
  )
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
  local_mocked_bindings(
    challenge_uncommitted_changes = function(...) invisible()
  )
  git_init()

  use_testthat()
  write_utf8(proj_path("tests", "testthat", "test-foo.txt"), "10")
  write_utf8(proj_path("tests", "testthat", "test-foo.R"), "test-foo.txt")

  rename_files("foo", "bar")
  expect_proj_file("tests/testthat/test-bar.txt")
  lines <- read_utf8(proj_path("tests", "testthat", "test-bar.R"))
  expect_equal(lines, "test-bar.txt")
})

test_that("does not remove non-R dots in filename", {
  create_local_package()
  local_mocked_bindings(
    challenge_uncommitted_changes = function(...) invisible()
  )
  git_init()

  file_create(proj_path("R/foo.bar.R"))
  rename_files("foo.bar", "baz.qux")
  expect_proj_file("R/baz.qux.R")
})
