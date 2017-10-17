context("git")

test_that("use_git_hook errors if project not using git", {
  tmp <- tempfile()
  create_package(tmp, rstudio = FALSE)
  expect_error(use_git_hook(
    "pre-commit",
    render_template("readme-rmd-pre-commit.sh"),
    base_path = tmp
  ),
  "This project doesn't use git")
})
