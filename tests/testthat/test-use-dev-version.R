context("use-dev-version.R")

test_that("use_dev_version() requires a package", {
  scoped_temporary_project()
  expect_error(use_dev_version(), "not an R package")
})

test_that("use_dev_version() appends .9000 to Version, exactly once", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)

  scoped_temporary_package()
  capture_output(
    use_description_field(name = "Version", value = "0.0.1", overwrite = TRUE)
  )
  capture_output(use_dev_version())
  expect_identical(
    as.character(desc::desc_get_version(proj_get())),
    "0.0.1.9000"
  )
  capture_output(use_dev_version())
  expect_identical(
    as.character(desc::desc_get_version(proj_get())),
    "0.0.1.9000"
  )
})
