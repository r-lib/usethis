context("test-roxygen")

test_that("use_package_doc() compatible with roxygen_ns_append()", {
  withr::local_options(list(usethis.quiet = FALSE))
  scoped_temporary_package()

  expect_output(use_package_doc())
  expect_output(roxygen_ns_append("test"), "Adding 'test'")
  expect_output(roxygen_ns_append("test"), NA)
})
