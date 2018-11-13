context("use_readme")

test_that("use_readme_md() creates README.md", {
  scoped_temporary_package()
  use_readme_md()
  expect_proj_file("README.md")
})

test_that("use_readme_rmd() creates README.Rmd", {
  skip_if_not_installed("rmarkdown")

  scoped_temporary_package()
  use_readme_rmd()
  expect_proj_file("README.Rmd")
})

test_that("use_readme_rmd() sets up git pre-commit hook if pkg uses git", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()
  skip_if_not_installed("rmarkdown")

  scoped_temporary_package()
  use_git()
  use_readme_rmd(open = FALSE)
  expect_proj_file(".git", "hooks", "pre-commit")
})
