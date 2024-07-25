test_that("we use specific URLs in a codecov badge", {
  create_local_package()
  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(use_codecov_badge("OWNER/REPO"))
})
