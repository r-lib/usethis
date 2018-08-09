context("use_readme")

test_that("message if try to overwrite existing file", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
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
  use_readme_rmd(open = FALSE)
  expect_false(file_exists(proj_path(".git", "hooks", "pre-commit")))
  use_git()
  use_readme_rmd(open = FALSE)
  expect_true(file_exists(proj_path(".git", "hooks", "pre-commit")))
})
