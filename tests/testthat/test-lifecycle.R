test_that("use_lifecycle() imports badges", {
  create_local_package(fs::path_temp("test_lifecycle"))
  use_package_doc()
  withr::local_options(usethis.quiet = FALSE)

  expect_snapshot({
    use_lifecycle()
  })

  expect_proj_file("man", "figures", "lifecycle-stable.svg")
  expect_equal(roxygen_ns_show(), "#' @importFrom lifecycle deprecated")
})
