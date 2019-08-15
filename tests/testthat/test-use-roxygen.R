context("use_roxygen_md")

test_that("use_roxygen_md() adds DESCRIPTION fields to naive package", {
  skip_if_not_installed("roxygen2")
  pkg <- scoped_temporary_package()
  use_roxygen_md()
  expect_identical(
    desc::desc_get("Roxygen", pkg),
    c(Roxygen = "list(markdown = TRUE)")
  )
  expect_true(desc::desc_has_fields("RoxygenNote", pkg))
  expect_true(uses_roxygen_md())
})

test_that("use_roxygen_md() does not error on a roxygen-using package", {
  skip_if_not_installed("roxygen2")
  with_mock(
    ## need to pass the check re: whether roxygen2md is installed
    `usethis:::check_installed` = function(pkg) TRUE, {
      scoped_temporary_package()
      cat(
        "RoxygenNote: 6.0.1\n",
        file = proj_path("DESCRIPTION"),
        append = TRUE
      )
      expect_error_free(use_roxygen_md())
    }
  )
})
