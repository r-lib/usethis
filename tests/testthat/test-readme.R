test_that("use_readme_md() creates README.md", {
  create_local_package()
  use_readme_md()
  expect_proj_file("README.md")
})

test_that("use_readme_rmd() creates README.Rmd", {
  skip_if_not_installed("rmarkdown")

  create_local_package()
  use_readme_rmd()
  expect_proj_file("README.Rmd")
})

test_that("use_readme_rmd() sets up git pre-commit hook if pkg uses git", {
  skip_if_no_git_user()
  skip_if_not_installed("rmarkdown")

  create_local_package()
  use_git()
  use_readme_rmd(open = FALSE)
  expect_proj_file(".git", "hooks", "pre-commit")
})
