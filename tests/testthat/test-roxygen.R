context("test-roxygen")

test_that("use_package_doc() compatible with roxygen_ns_append()", {
  scoped_temporary_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_output(use_package_doc())
  expect_output(roxygen_ns_append("test"), "Adding 'test'")
  expect_silent(roxygen_ns_append("test"))
})
