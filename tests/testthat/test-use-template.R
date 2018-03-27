context("use_template")

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

test_that("find_template can find templates for tricky Rbuildignored files", {
  expect_match(find_template("travis.yml"), "travis\\.yml$")
  expect_match(find_template("codecov.yml"), "codecov\\.yml$")
  expect_match(find_template("cran-comments.md"), "cran-comments\\.md$")
  expect_match(find_template("template.Rproj"), "template\\.Rproj$")
})

