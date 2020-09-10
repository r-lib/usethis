test_that("use_mit_license() works", {
  create_local_package()
  use_mit_license()

  expect_equal(desc::desc_get("License", proj_get())[[1]], "MIT + file LICENSE")

  expect_proj_file("LICENSE.md")
  expect_true(is_build_ignored("^LICENSE\\.md$"))

  expect_proj_file("LICENSE")
  expect_false(is_build_ignored("^LICENSE$"))
})

test_that("other licenses work without error", {
  create_local_package()

  expect_error(use_agpl3_license(), NA)
  expect_error(use_apl2_license(), NA)
  expect_error(use_cc0_license(), NA)
  expect_error(use_ccby_license(), NA)
  expect_error(use_gpl3_license(), NA)
  expect_error(use_lgpl_license(), NA)
})
