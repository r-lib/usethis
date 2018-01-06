context("helpers")

test_that("use_description_field() can address an existing field", {
  pkg <- scoped_temporary_package()
  orig <- tools::md5sum(proj_path("DESCRIPTION"))

  ## specify existing value of existing field --> should be no op
  use_description_field(
    name = "Version",
    value = desc::desc_get("Version", pkg)[[1]],
    base_path = pkg
  )
  expect_identical(orig, tools::md5sum(proj_path("DESCRIPTION")))

  expect_error(
    use_description_field(
      name = "Version",
      value = "1.1.1",
      base_path = pkg
    ),
    "has a different value"
  )

  ## overwrite existing field
  capture_output(
    use_description_field(
      name = "Version",
      value = "1.1.1",
      base_path = pkg,
      overwrite = TRUE
    )
  )
  expect_identical(c(Version = "1.1.1"), desc::desc_get("Version", pkg))
})

test_that("use_description_field() can add new field", {
  pkg <- scoped_temporary_package()
  capture_output(
    use_description_field(name = "foo", value = "bar", base_path = pkg)
  )
  expect_identical(c(foo = "bar"), desc::desc_get("foo", pkg))
})
