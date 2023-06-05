test_that("bump_version() presents all possible incremented versions", {
  expect_identical(
    bump_version("1.1.1.9000"),
    c(major = "2.0.0", minor = "1.2.0", patch = "1.1.2", dev = "1.1.1.9001")
  )
})

test_that("use_version() and use_dev_version() require a package", {
  create_local_project()
  expect_usethis_error(use_version("major"), "not an R package")
  expect_usethis_error(use_dev_version(), "not an R package")
})

test_that("use_version() errors for invalid `which`", {
  create_local_package()
  expect_snapshot(error = TRUE, use_version("1.2.3"))
})

test_that("use_version() increments version in DESCRIPTION, edits NEWS", {
  create_local_package()
  proj_desc_field_update(
    key = "Version",
    value = "1.1.1.9000",
    overwrite = TRUE
  )
  local_cran_version("1.1.1")
  use_news_md()

  use_version("major")
  expect_identical(proj_version(), "2.0.0")

  expect_snapshot(
    writeLines(read_utf8(proj_path("NEWS.md"))),
    transform = scrub_testpkg
  )
})

test_that("use_dev_version() appends .9000 to Version, exactly once", {
  create_local_package()
  proj_desc_field_update(key = "Version", value = "0.0.1", overwrite = TRUE)
  use_dev_version()
  expect_identical(proj_version(), "0.0.1.9000")
  use_dev_version()
  expect_identical(proj_version(), "0.0.1.9000")
})

test_that("use_version() updates (development version) directly", {
  create_local_package()
  proj_desc_field_update(key = "Version", value = "0.0.1", overwrite = TRUE)
  local_cran_version("0.0.1")
  use_news_md()

  # bump to dev to set (development version)
  use_dev_version()

  # directly overwrite development header
  use_version("patch")

  expect_snapshot(
    writeLines(read_utf8(proj_path("NEWS.md"))),
    transform = scrub_testpkg
  )
})

test_that("use_version() updates version.c", {
  create_local_package()
  proj_desc_field_update(key = "Version", value = "1.0.0", overwrite = TRUE)

  name <- project_name()
  src_path <- proj_path("src")
  ver_path <- path(src_path, "version.c")
  dir_create(src_path)

  write_utf8(ver_path, glue('
    foo;
    const char {name}_version = "1.0.0";
    bar;'))

  use_dev_version()

  lines <- read_utf8(ver_path)
  expect_snapshot(writeLines(lines), transform = scrub_testpkg)
})

test_that("is_dev_version() detects dev version directly and with DESCRIPTION", {
  expect_true(is_dev_version("0.0.1.9000"))
  expect_false(is_dev_version("0.0.1"))

  create_local_package()
  proj_desc_field_update(key = "Version", value = "1.0.0", overwrite = TRUE)
  expect_false(is_dev_version())
  use_dev_version()
  expect_true(is_dev_version())
})
