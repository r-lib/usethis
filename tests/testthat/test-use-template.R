context("template")

test_that("error if try to overwrite existing file", {
  dir <- scoped_temporary_package()
  expect_error(
    use_template("NEWS.md", "DESCRIPTION"),
    "already exists"
  )
})

# helpers -----------------------------------------------------------------

test_that("find_template errors if template missing", {
  expect_error(find_template("xxx"), "Could not find template")
})

