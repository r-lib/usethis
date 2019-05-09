context("helpers")

test_that("create_directory() doesn't bother a pre-existing target dir", {
  tmp <- file_temp()
  dir_create(tmp)
  expect_true(is_dir(tmp))
  expect_error_free(create_directory(tmp))
  expect_true(is_dir(tmp))
})

test_that("create_directory() creates a directory", {
  tmp <- file_temp("yes")
  create_directory(tmp)
  expect_true(is_dir(tmp))
})

test_that("edit_file() creates new directory and another and a file within", {
  tmp <- file_temp()
  expect_false(dir_exists(tmp))
  capture.output(new_file <- edit_file(path(tmp, "new_dir", "new_file")))
  expect_true(dir_exists(tmp))
  expect_true(dir_exists(path(tmp, "new_dir")))
  expect_true(file_exists(path(tmp, "new_dir", "new_file")))
})

test_that("edit_file() creates new file in existing directory", {
  tmp <- file_temp()
  dir_create(tmp)
  capture.output(new_file <- edit_file(path(tmp, "new_file")))
  expect_true(file_exists(path(tmp, "new_file")))
})

test_that("edit_file() copes with path to existing file", {
  tmp <- file_temp()
  dir_create(tmp)
  existing <- file_create(path(tmp, "a_file"))
  capture.output(res <- edit_file(path(tmp, "a_file")))
  expect_identical(existing, res)
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

  expect_usethis_error(
    use_description_field(
      name = "Version",
      value = "1.1.1",
      base_path = pkg
    ),
    "has a different value"
  )

  ## overwrite existing field
  use_description_field(
    name = "Version",
    value = "1.1.1",
    base_path = pkg,
    overwrite = TRUE
  )
  expect_identical(c(Version = "1.1.1"), desc::desc_get("Version", pkg))
})

test_that("use_description_field() can add new field", {
  pkg <- scoped_temporary_package()
  use_description_field(name = "foo", value = "bar", base_path = pkg)
  expect_identical(c(foo = "bar"), desc::desc_get("foo", pkg))
})

test_that("use_description_field() ignores whitespace", {
  pkg <- scoped_temporary_package()
  use_description_field(name = "foo", value = "\n bar")
  use_description_field(name = "foo", value = "bar")
  expect_identical(c(foo = "\n bar"), desc::desc_get("foo", pkg))
})

test_that("valid_package_name() enforces valid package names", {
  # Contain only ASCII letters, numbers, and '.'
  # Have at least two characters
  # Start with a letter
  # Not end with '.'

  expect_true(valid_package_name("aa"))
  expect_true(valid_package_name("a7"))
  expect_true(valid_package_name("a.2"))

  expect_false(valid_package_name("a"))
  expect_false(valid_package_name("a-2"))
  expect_false(valid_package_name("2fa"))
  expect_false(valid_package_name(".fa"))
  expect_false(valid_package_name("aa\u00C0")) # \u00C0 is a-grave
  expect_false(valid_package_name("a3."))
})

test_that("valid_file_name() enforces valid file names", {
  # Contain only ASCII letters, numbers, '-', and '_'
  expect_true(valid_file_name("aa.R"))
  expect_true(valid_file_name("a7.R"))
  expect_true(valid_file_name("a-2.R"))
  expect_true(valid_file_name("a_2.R"))
  expect_false(valid_file_name("aa\u00C0.R")) # \u00C0 is a-grave
  expect_false(valid_file_name("a?3.R"))
})
