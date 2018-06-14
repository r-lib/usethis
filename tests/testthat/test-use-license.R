context("use_license")

test_that("find_name() errors when no name seems to be intentionally set", {
  withr::with_options(
    list(usethis.full_name = NULL, devtools.name = NULL),
    expect_error(find_name(), ".*name.* argument is missing")
  )
  withr::with_options(
    list(usethis.full_name = NULL, devtools.name = "Your name goes here"),
    expect_error(find_name(), ".*name.* argument is missing")
  )
})

test_that("find_name() picks up usethis.full_name, then devtools.name", {
  withr::with_options(
    list(
      usethis.full_name = "usethis.full_name",
      devtools.name = "devtools.name"
    ),
    expect_identical(find_name(), "usethis.full_name")
  )
  withr::with_options(
    list(
      usethis.full_name = NULL,
      devtools.name = "devtools.name"
    ),
    expect_identical(find_name(), "devtools.name")
  )
})

test_that("use_mit_license() works", {
  pkg <- scoped_temporary_package()
  capture_output(use_mit_license(name = "MIT License"))
  expect_match(desc::desc_get("License", file = pkg), "MIT [+] file LICENSE")
  expect_true(file_exists(proj_path("LICENSE.md")))
  expect_true(file_exists(proj_path("LICENSE")))
  expect_true(is_build_ignored("^LICENSE\\.md$"))
  expect_true(is_build_ignored("^LICENSE$", invert = TRUE))
})

test_that("use_gpl3_license() works", {
  pkg <- scoped_temporary_package()
  capture_output(use_gpl3_license(name = "GPL3 License"))
  expect_match(desc::desc_get("License", file = pkg), "GPL-3")
  expect_true(file_exists(proj_path("LICENSE.md")))
  expect_true(is_build_ignored("^LICENSE\\.md$"))
})

test_that("use_apl2_license() works", {
  pkg <- scoped_temporary_package()
  capture_output(use_apl2_license(name = "Apache License"))
  expect_match(desc::desc_get("License", file = pkg), "Apache")
  expect_true(file_exists(proj_path("LICENSE.md")))
  expect_true(is_build_ignored("^LICENSE\\.md$"))
})

test_that("use_cc0_license() works", {
  pkg <- scoped_temporary_package()
  capture_output(use_cc0_license(name = "CC0 License"))
  expect_match(desc::desc_get("License", file = pkg), "CC0")
  expect_true(file_exists(proj_path("LICENSE.md")))
  expect_true(is_build_ignored("^LICENSE\\.md$"))
})
