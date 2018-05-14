context("use_readme")

test_that("error if try to overwrite existing file", {
  skip_if_not_installed("rmarkdown")

  scoped_temporary_package()
  file.create(proj_path("README.md"))
  expect_message(use_readme_md(), "not written")
  file.create(proj_path("README.Rmd"))
  expect_message(use_readme_rmd(), "not written")
})

test_that("sets up git pre-commit hook iff pkg uses git", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()
  skip_if_not_installed("rmarkdown")

  scoped_temporary_package()
  capture_output(use_readme_rmd(open = FALSE))
  expect_false(file.exists(proj_path(".git", "hooks", "pre-commit")))
  capture_output(use_git())
  capture_output(use_readme_rmd(open = FALSE))
  expect_true(file.exists(proj_path(".git", "hooks", "pre-commit")))
})
