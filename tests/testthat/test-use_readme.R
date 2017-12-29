context("readme")

test_that("error if try to overwrite existing file", {
  tmp <- scoped_temporary_package()
  file.create(file.path(tmp, "README.md"))
  expect_error(use_readme_md(), "already exists")
  file.create(file.path(tmp, "README.Rmd"))
  expect_error(use_readme_rmd(), "already exists")
})

test_that("sets up git pre-commit hook iff pkg uses git", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
  tmp <- scoped_temporary_package()
  capture_output(use_readme_rmd(open = FALSE))
  expect_false(file.exists(file.path(tmp, ".git", "hooks", "pre-commit")))
  capture_output(use_git())
  capture_output(use_readme_rmd(open = FALSE))
  expect_true(file.exists(file.path(tmp, ".git", "hooks", "pre-commit")))
})
