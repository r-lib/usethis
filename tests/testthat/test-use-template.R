context("template")

test_that("error if try to overwrite existing file", {
  expect_error(
    use_template("NEWS.md", "test-use-template.R", base_path = test_path()),
    "already exists"
  )
})

# helpers -----------------------------------------------------------------

test_that("find_template errors if template missing", {
  expect_error(find_template("xxx"), "Could not find template")
})

