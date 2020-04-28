context("use_pkgdown")

test_that("use_pkgdown() requires a package", {
  create_local_project()
  expect_usethis_error(use_pkgdown(), "not an R package")
})

test_that("use_pkgdown() creates and ignores the promised file/dir", {
  skip_if_not_installed("pkgdown", "1.1.0")
  create_local_package()
  use_pkgdown()
  expect_proj_file("_pkgdown.yml")
  expect_true(is_build_ignored("^_pkgdown\\.yml$"))
  expect_true(is_build_ignored("^docs$"))
})
