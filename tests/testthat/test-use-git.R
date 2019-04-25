context("git")

test_that('use_git_config(scope = "project) errors if project not using git', {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
  scoped_temporary_package()
  expect_error(
    use_git_config(scope = "project", user.name = "USER.NAME"),
    "Cannot detect that project is already a Git repository"
  )
})

test_that("use_git_config() can set local config", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()

  scoped_temporary_package()
  use_git()
  use_git_config(
    scope = "project",
    user.name = "Jane",
    user.email = "jane@example.org"
  )
  r <- git2r::repository(proj_get())
  cfg <- git2r::config(repo = r, global = FALSE)
  expect_identical(cfg$local$user.name, "Jane")
  expect_identical(cfg$local$user.email, "jane@example.org")
})

test_that("use_git_hook errors if project not using git", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
  scoped_temporary_package()
  expect_error(
    use_git_hook(
      "pre-commit",
      render_template("readme-rmd-pre-commit.sh")
    ),
    "Cannot detect that project is already a Git repository"
  )
})

test_that("git remote handlers work", {
  # git2r::git2r::discover_repository() not working on R 3.1 (Travis)
  skip_if(getRversion() < 3.2)
  skip_if_no_git_config()

  scoped_temporary_package()
  use_git()

  expect_null(git_remotes())

  use_git_remote(name = "foo", url = "foo_url")
  expect_identical(git_remotes(), list(foo = "foo_url"))

  use_git_remote(name = "foo", url = "new_url", overwrite = TRUE)
  expect_identical(git_remotes(), list(foo = "new_url"))

  use_git_remote(name = "foo", url = NULL, overwrite = TRUE)
  expect_null(git_remotes())
})
