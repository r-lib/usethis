context("use-cran-comments")

test_that("use_cran_comments() requires a package", {
  scoped_temporary_project()
  expect_usethis_error(use_cran_comments(), "not an R package")
})

test_that("use_cran_comments() creates and ignores the promised file", {
  scoped_temporary_package()
  use_cran_comments()
  expect_proj_file("cran-comments.md")
  expect_true(is_build_ignored("^cran-comments\\.md$"))
})
