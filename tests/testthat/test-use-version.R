context("use_version.R")

test_that("use_version() requires a package", {
  scoped_temporary_project()
  expect_error(use_version(), "not an R package")
})

test_that("use_version() increments Mayor by 1 and resets other fields", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)

  scoped_temporary_package()
  capture_output(
    use_description_field(name = "Version", value = "0.1.1.9000", overwrite = TRUE)
  )
  capture_output(use_version(level = "Mayor"))
  expect_identical(
    as.character(desc::desc_get_version(proj_get())),
    "1.0.0.9000"
  )
})

test_that("use_version() increments Minor by 1 and only resets Patch", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)

  scoped_temporary_package()
  capture_output(
    use_description_field(name = "Version", value = "1.1.1.9000", overwrite = TRUE)
  )
  capture_output(use_version(level = "Minor"))
  expect_identical(
    as.character(desc::desc_get_version(proj_get())),
    "1.2.0.9000"
  )
})

test_that("use_version() increments patch by 1 leaving other fields alone", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)

  scoped_temporary_package()
  capture_output(
    use_description_field(name = "Version", value = "1.1.1.9000", overwrite = TRUE)
  )
  capture_output(use_version(level = "Patch"))
  expect_identical(
    as.character(desc::desc_get_version(proj_get())),
    "1.1.2.9000"
  )
})
