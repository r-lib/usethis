context("use_version.R")

test_that("bump_version() presents all possible incremented versions", {
  expect_identical(
    bump_version("1.1.1.9000"),
    c(major = "2.0.0", minor = "1.2.0", patch = "1.1.2", dev = "1.1.1.9001")
  )
})

test_that("use_version() and use_dev_version() require a package", {
  scoped_temporary_project()
  expect_error(use_version("major"), "not an R package")
  expect_error(use_dev_version(), "not an R package")
})

test_that("use_version() errors for invalid `which`", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)

  scoped_temporary_package()
  expect_error(use_version("1.2.3"), "should be one of")
})

test_that("use_version() increments version in DESCRIPTION, edits NEWS", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)

  scoped_temporary_package()
  use_description_field(
    name = "Version",
    value = "1.1.1.9000",
    overwrite = TRUE
  )
  use_news_md()

  use_version("major")
  expect_identical(
    as.character(desc::desc_get_version(proj_get())),
    "2.0.0"
  )
  expect_match(
    readLines(proj_path("NEWS.md"), n = 1),
    "2.0.0"
  )
})

test_that("use_dev_version() appends .9000 to Version, exactly once", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)

  scoped_temporary_package()
  use_description_field(name = "Version", value = "0.0.1", overwrite = TRUE)
  use_dev_version()
  expect_identical(
    as.character(desc::desc_get_version(proj_get())),
    "0.0.1.9000"
  )
  use_dev_version()
  expect_identical(
    as.character(desc::desc_get_version(proj_get())),
    "0.0.1.9000"
  )
})
