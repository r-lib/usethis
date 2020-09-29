test_that("use_package_doc() compatible with roxygen_ns_append()", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_message(use_package_doc())
  expect_message(roxygen_ns_append("test"), "Adding 'test'")
  expect_silent(roxygen_ns_append("test"))
})

test_that("use_roxygen_md() adds DESCRIPTION fields to naive package", {
  skip_if_not_installed("roxygen2")
  pkg <- create_local_package()
  use_roxygen_md()
  expect_identical(
    desc::desc_get("Roxygen", pkg),
    c(Roxygen = "list(markdown = TRUE)")
  )
  expect_true(desc::desc_has_fields("RoxygenNote", pkg))
  expect_true(uses_roxygen_md())
})
