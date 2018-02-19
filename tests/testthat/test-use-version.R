context("use_version.R")

test_that("bump_version() increments Major by 1 and resets other fields", {

  scoped_temporary_package()
  capture_output(
    use_description_field(name = "Version", value = "1.1.1.9000", overwrite = TRUE)
  )
  expect_identical(
    as.character(bump_version(desc::desc_get_version(proj_get()), "major")),
    "2.0.0"
  )
  expect_identical(
    as.character(bump_version(desc::desc_get_version(proj_get()), "minor")),
    "1.2.0"
  )
  expect_identical(
    as.character(bump_version(desc::desc_get_version(proj_get()), "patch")),
    "1.1.2"
  )
  expect_identical(
    as.character(bump_version(desc::desc_get_version(proj_get()), "dev")),
    "1.1.1.9001"
  )

  capture_output(
    use_description_field(name = "Version", value = "1.1.1", overwrite = TRUE)
  )
  expect_identical(
    as.character(bump_version(desc::desc_get_version(proj_get()), "dev")),
    "1.1.1.9000"
  )
})

test_that("use_version() increments major and resets other fields to 0", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)

  scoped_temporary_package()
  capture_output(
    use_description_field(name = "Version", value = "1.1.1.9000", overwrite = TRUE)
  )
  capture_output(use_version("major"))
  expect_identical(
    as.character(desc::desc_get_version(proj_get())),
    "2.0.0"
  )
})

test_that("use_version() requires a package", {
  scoped_temporary_project()
  expect_error(use_version("major"), "not an R package")
})
