context("use_version.R")

test_that("bump_version() presents all possible incremented versions", {
  expect_identical(
    bump_version("1.1.1.9000"),
    c(major = "2.0.0", minor = "1.2.0", patch = "1.1.2", dev = "1.1.1.9001")
  )
})

test_that("use_version() and use_dev_version() require a package", {
  scoped_temporary_project()
  expect_usethis_error(use_version("major"), "not an R package")
  expect_usethis_error(use_dev_version(), "not an R package")
})

test_that("use_version() errors for invalid `which`", {
  scoped_temporary_package()
  expect_error(use_version("1.2.3"), "should be one of")
})

test_that("use_version() increments version in DESCRIPTION, edits NEWS", {
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

test_that("use_version() updates (development version) directly", {
  scoped_temporary_package()
  use_description_field(name = "Version", value = "0.0.1", overwrite = TRUE)
  use_news_md()

  # bump to dev to set (development version)
  use_dev_version()

  # directly overwrite development header
  use_version("patch")

  expect_match(
    readLines(proj_path("NEWS.md"), n = 1),
    "0[.]0[.]2"
  )

  expect_match(
    readLines(proj_path("NEWS.md"), n = 3)[3],
    "0[.]0[.]1"
  )
})
