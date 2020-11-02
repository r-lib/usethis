test_that("can leave existing file unchanged, without an error", {
  create_local_package()
  desc_lines_before <- read_utf8(proj_path("DESCRIPTION"))
  expect_error_free(
    use_template("NEWS.md", "DESCRIPTION")
  )
  desc_lines_after <- read_utf8(proj_path("DESCRIPTION"))
  expect_identical(desc_lines_before, desc_lines_after)
})

# helpers -----------------------------------------------------------------

test_that("find_template errors if template missing", {
  expect_usethis_error(find_template("xxx"), "Could not find template")
})

test_that("find_template can find templates for tricky Rbuildignored files", {
  expect_match(find_template("travis.yml"), "travis\\.yml$")
  expect_match(find_template("codecov.yml"), "codecov\\.yml$")
  expect_match(find_template("cran-comments.md"), "cran-comments\\.md$")
  expect_match(find_template("template.Rproj"), "template\\.Rproj$")
})
