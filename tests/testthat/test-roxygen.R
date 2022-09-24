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
  expect_equal(
    desc::desc_get("Roxygen", pkg),
    c(Roxygen = "list(markdown = TRUE)")
  )
  expect_true(desc::desc_has_fields("RoxygenNote", pkg))
  expect_true(uses_roxygen_md())
})

test_that("use_roxygen_md() behaves for pre-existing Roxygen field", {
  skip_if_not_installed("roxygen2")

  pkg <- create_local_package()
  desc::desc_set(Roxygen = "list(markdown = TRUE, r6 = FALSE)")

  expect_error(use_roxygen_md(), "already has")
  with_mock(
    # in case roxygen2md is not installed
    check_installed = function(pkg) TRUE,
    {
      expect_without_error(use_roxygen_md(overwrite = TRUE))
    }
  )
  expect_true(uses_roxygen_md())
})
