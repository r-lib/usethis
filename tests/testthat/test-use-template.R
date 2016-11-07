context("template")

test_that("error if try to overwrite existing file", {
  expect_error(
    use_template("NEWS.md", "test-use-template.R", base_path = test_path()),
    "'./test-use-template.R' already exists"
  )
})

test_that("only message about generating template if it already exists", {
  expect_message(
    use_template("NEWS.md", base_path = test_path("use_template")),
    "Generating template",
    all = TRUE
  )
})


# helpers -----------------------------------------------------------------

test_that("find_template errors if template missing", {
  expect_error(find_template("xxx"), "Could not find template")
})

