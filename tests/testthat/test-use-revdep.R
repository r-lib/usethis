context("use_revdep")

test_that("use_revdep() requires a package", {
  scoped_temporary_project()
  expect_error(use_revdep(), "not an R package")
})

test_that("use_revdep() creates and ignores files/dirs", {
  scoped_temporary_package()
  capture_output(use_revdep())
  expect_true(file_exists(proj_path("revdep/email.yml")))
  expect_true(file_exists(proj_path("revdep/.gitignore")))
  expect_true(is_build_ignored("^revdep$"))
})
