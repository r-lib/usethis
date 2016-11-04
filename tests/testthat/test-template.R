context("template")

test_that("render_template errors if template missing", {
  expect_error(render_template("xxx", "xxx"), "Could not find template")
})

test_that("error if try to overwrite existing file", {
  expect_error(
    render_template("NEWS.md", "test-template.R", base_path = test_path()),
    "'test-template.R' already exists"
  )
})
