context("use_pkgdown")

test_that("use_pkgdown() requires a package", {
  scoped_temporary_project()
  expect_error(use_pkgdown(), "not an R package")
})

test_that("use_package_doc() creates and ignores the promised file/dir", {
  scoped_temporary_package()
  use_pkgdown()
  expect_proj_file("_pkgdown.yml")
  expect_proj_dir("docs")
  expect_true(is_build_ignored("^_pkgdown\\.yml$"))
  expect_true(is_build_ignored("^docs$"))
})
