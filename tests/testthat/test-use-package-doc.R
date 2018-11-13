context("use_package_doc")

test_that("use_package_doc() requires a package", {
  scoped_temporary_project()
  expect_error(use_package_doc(), "not an R package")
})

test_that("use_package_doc() creates the promised file", {
  scoped_temporary_package()
  use_package_doc()
  expect_proj_file("R", paste0(project_name(), "-package.R"))
})
