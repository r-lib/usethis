context("test-roxygen")

test_that("use_package_doc() compatible with roxygen_ns_append()", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_message(use_package_doc())
  expect_message(roxygen_ns_append("test"), "Adding 'test'")
  expect_silent(roxygen_ns_append("test"))
})
