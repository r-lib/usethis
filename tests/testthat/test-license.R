test_that("use_mit_license() works", {
  create_local_package()
  use_mit_license()

  expect_equal(desc::desc_get_field("License"), "MIT + file LICENSE")

  expect_proj_file("LICENSE.md")
  expect_true(is_build_ignored("^LICENSE\\.md$"))

  expect_proj_file("LICENSE")
  expect_false(is_build_ignored("^LICENSE$"))
})

test_that("use_proprietary_license() works", {
  create_local_package()
  use_proprietary_license("foo")

  expect_equal(desc::desc_get_field("License"), "file LICENSE")
  expect_proj_file("LICENSE")
  # TODO add snapshot test
})

test_that("other licenses work without error", {
  create_local_package()

  expect_no_error(use_agpl_license(3))
  expect_no_error(use_apache_license(2))
  expect_no_error(use_cc0_license())
  expect_no_error(use_ccby_license())
  expect_no_error(use_gpl_license(2))
  expect_no_error(use_gpl_license(3))
  expect_no_error(use_lgpl_license(2.1))
  expect_no_error(use_lgpl_license(3))

  # old fallbacks
  expect_no_error(use_agpl3_license())
  expect_no_error(use_gpl3_license())
  expect_no_error(use_apl2_license())
})

test_that("check license gives useful errors", {
  expect_usethis_error(check_license_version(1, 2), "must be 2")
  expect_usethis_error(check_license_version(1, 2:4), "must be 2, 3, or 4")
})

test_that("generate correct abbreviations", {
  expect_equal(license_abbr("GPL", 2, TRUE), "GPL (>= 2)")
  expect_equal(license_abbr("GPL", 2, FALSE), "GPL-2")
  expect_equal(
    license_abbr("Apache License", 2, FALSE),
    "Apache License (== 2)"
  )
})
