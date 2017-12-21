context("git")

test_that("use_git_hook errors if project not using git", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
  scoped_temporary_package()
  expect_error(
    use_git_hook(
      "pre-commit",
      render_template("readme-rmd-pre-commit.sh")
    ),
    "This project doesn't use git"
  )
})
