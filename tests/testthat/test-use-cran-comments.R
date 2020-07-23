test_that("use_cran_comments() requires a package", {
  create_local_project()
  expect_usethis_error(use_cran_comments(), "not an R package")
})

test_that("use_cran_comments() creates and ignores the promised file", {
  create_local_package()
  use_cran_comments()
  expect_proj_file("cran-comments.md")
  expect_true(is_build_ignored("^cran-comments\\.md$"))
})
