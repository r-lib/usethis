test_that("use_package_doc() requires a package", {
  create_local_project()
  expect_false(has_package_doc())
  expect_usethis_error(use_package_doc(), "not an R package")
})

test_that("use_package_doc() creates the promised file", {
  create_local_package()
  use_package_doc()
  expect_proj_file("R", paste0(project_name(), "-package.R"))
  expect_true(has_package_doc())
})
