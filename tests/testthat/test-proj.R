context("projects")

test_that("proj_set() errors on non-existent path", {
  expect_error(
    proj_set("abcedefgihklmnopqrstuv"),
    "Directory does not exist"
  )
})

test_that("proj_set() errors if no criteria are fulfilled", {
  tmpdir <- tempfile(pattern = "i-am-not-a-project")
  on.exit(unlink(tmpdir, recursive = TRUE))
  dir.create(tmpdir)
  expect_error(
    proj_set(tmpdir),
    "does not appear to be inside a project or package"
  )
})

test_that("proj_set() can be forced, even if no criteria are fulfilled", {
  tmpdir <- tempfile(pattern = "i-am-not-a-project")
  on.exit(unlink(tmpdir, recursive = TRUE))
  dir.create(tmpdir)
  expect_error_free(proj_set(tmpdir, force = TRUE))
  expect_identical(proj$cur, tmpdir)
  expect_error_free(proj_get())
  expect_error(
    proj_set(proj_get()),
    "does not appear to be inside a project or package"
  )
})

test_that("is_package() detects package-hood", {
  scoped_temporary_package()
  expect_true(is_package())

  scoped_temporary_project()
  expect_false(is_package())
})

test_that("check_is_package() errors for non-package", {
  scoped_temporary_project()
  expect_error(check_is_package(), "not an R package")
})

test_that("check_is_package() can reveal who's asking", {
  scoped_temporary_project()
  expect_error(check_is_package("foo"), "foo")
})
