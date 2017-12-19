context("readme")

test_that("error if try to overwrite existing file", {
  tmp <- tempfile()
  create_package(tmp, rstudio = FALSE)
  file.create(file.path(tmp, "README.md"))
  expect_error(use_readme_md(tmp),
               "already exists")
  file.create(file.path(tmp, "README.Rmd"))
  expect_error(use_readme_rmd(tmp),
               "already exists")
})

test_that("sets up git pre-commit hook iff pkg uses git", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
  tmp <- tempfile()
  create_package(tmp, rstudio = FALSE)
  use_readme_rmd(open = FALSE)
  expect_false(file.exists(file.path(tmp, ".git", "hooks", "pre-commit")))
  use_git()
  use_readme_rmd(open = FALSE)
  expect_true(file.exists(file.path(tmp, ".git", "hooks", "pre-commit")))
})
