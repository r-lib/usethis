test_that("use_lifecycle() imports badges", {
  create_local_package()
  use_package_doc()
  withr::local_options(usethis.quiet = FALSE, width = 200)

  expect_snapshot(
    use_lifecycle(),
    transform = scrub_testpkg
  )

  expect_proj_file("man", "figures", "lifecycle-stable.svg")
  expect_equal(roxygen_ns_show(), "#' @importFrom lifecycle deprecated")
})
