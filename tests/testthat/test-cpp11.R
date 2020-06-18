context("use_cpp11")

test_that("use_cpp11() requires a package", {
  create_local_project()
  expect_usethis_error(use_cpp11(), "not an R package")
})

test_that("use_cpp11() creates files/dirs, edits DESCRIPTION and .gitignore", {
  pkg <- create_local_package()
  use_roxygen_md()

  use_cpp11()
  expect_match(desc::desc_get("LinkingTo", pkg), "cpp11")
  expect_proj_dir("src")

  ignores <- read_utf8(proj_path("src", ".gitignore"))
  expect_true(all(c("*.o", "*.so", "*.dll") %in% ignores))
})
