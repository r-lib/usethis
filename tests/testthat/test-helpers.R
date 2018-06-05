context("helpers")

test_that("create_directory() requires base_path to be pre-existing directory", {
  tmp <- tempfile()
  expect_error(create_directory(tmp, "nope"), "does not exist")
  writeLines("I exist now", tmp)
  expect_error(create_directory(tmp, "nope"), "not a directory")
})

test_that("create_directory() doesn't bother a pre-existing target dir", {
  tmp <- tempfile()
  dir_create(tmp)
  expect_true(is_dir(tmp))
  expect_error_free(create_directory(path_dir(tmp), path_file(tmp)))
  expect_true(is_dir(tmp))
})

test_that("create_directory() catches if pre-existing target is not a dir", {
  tmp <- tempfile()
  file_create(tmp)
  expect_false(is_dir(tmp))
  expect_error(
    create_directory(path_dir(tmp), path_file(tmp)),
    "exists but is not a directory"
  )
})

test_that("create_directory() creates a directory", {
  tmp <- tempfile()
  dir_create(tmp)
  new_dir <- create_directory(tmp, "yes")
  expect_true(is_dir(new_dir))
})

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
