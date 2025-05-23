test_that("uses_git() works", {
  skip_if_no_git_user()

  create_local_package()
  expect_false(uses_git())
  expect_usethis_error(check_uses_git())

  git_init()

  expect_true(uses_git())
  expect_no_error(check_uses_git())
})

test_that('use_git_config(scope = "project") errors if project not using git', {
  create_local_package()
  expect_usethis_error(
    use_git_config(scope = "project", user.name = "USER.NAME"),
    "Cannot detect that project is already a Git repository"
  )
})

test_that("use_git_config() can set local config", {
  skip_if_no_git_user()

  create_local_package()
  use_git()
  use_git_config(
    scope = "project",
    user.name = "Jane",
    user.email = "jane@example.org",
    init.defaultBranch = "main"
  )
  r <- git_repo()
  expect_identical(git_cfg_get("user.name", "local"), "Jane")
  expect_identical(git_cfg_get("user.email", "local"), "jane@example.org")
  expect_identical(git_cfg_get("init.defaultBranch", "local"), "main")
  expect_identical(git_cfg_get("init.defaultbranch", "local"), "main")
})

test_that("use_git_config() can set a non-existing config field", {
  skip_if_no_git_user()

  create_local_package()
  use_git()

  expect_null(git_cfg_get("aaa.bbb"))
  use_git_config(scope = "project", aaa.bbb = "ccc")
  expect_identical(git_cfg_get("aaa.bbb"), "ccc")
})

test_that("use_git_config() facilitates round trips", {
  skip_if_no_git_user()

  create_local_package()
  use_git()

  orig <- use_git_config(scope = "project", aaa.bbb = "ccc")
  expect_null(orig$aaa.bbb)
  expect_identical(git_cfg_get("aaa.bbb"), "ccc")

  new <- use_git_config(scope = "project", aaa.bbb = NULL)
  expect_identical(new$aaa.bbb, "ccc")
  expect_null(git_cfg_get("aaa.bbb"))
})

test_that("use_git_hook errors if project not using git", {
  create_local_package()
  expect_usethis_error(
    use_git_hook(
      "pre-commit",
      render_template("readme-rmd-pre-commit.sh")
    ),
    "Cannot detect that project is already a Git repository"
  )
})

test_that("git remote handlers work", {
  skip_if_no_git_user()

  create_local_package()
  use_git()

  expect_null(git_remotes())

  use_git_remote(name = "foo", url = "foo_url")
  expect_identical(git_remotes(), list(foo = "foo_url"))

  use_git_remote(name = "foo", url = "new_url", overwrite = TRUE)
  expect_identical(git_remotes(), list(foo = "new_url"))

  use_git_remote(name = "foo", url = NULL, overwrite = TRUE)
  expect_null(git_remotes())
})
