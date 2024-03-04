test_that("use_package_doc() compatible with roxygen_ns_append()", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_snapshot(use_package_doc(), transform = scrub_testpkg)
  expect_snapshot(roxygen_ns_append("test"), transform = scrub_testpkg)
  expect_silent(roxygen_ns_append("test"))
})

test_that("use_roxygen_md() adds DESCRIPTION fields to naive package", {
  skip_if_not_installed("roxygen2")

  pkg <- create_local_package()
  use_roxygen_md()

  desc <- proj_desc()
  expect_equal(desc$get("Roxygen"), c(Roxygen = "list(markdown = TRUE)"))
  expect_true(desc$has_fields("RoxygenNote"))
  expect_true(uses_roxygen_md())
})

test_that("use_roxygen_md() behaves for pre-existing Roxygen field", {
  skip_if_not_installed("roxygen2")

  pkg <- create_local_package()
  desc::desc_set(Roxygen = 'list(markdown = TRUE, r6 = FALSE, load = "source")')

  expect_error(use_roxygen_md(), "already has")
  local_check_installed()
  expect_no_error(use_roxygen_md(overwrite = TRUE))
  expect_true(uses_roxygen_md())
})
