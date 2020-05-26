test_that("uses_git() works", {
  skip_if_no_git_user()

  create_local_package()
  expect_false(uses_git())
  expect_error(check_uses_git())

  git_init()

  expect_true(uses_git())
  expect_error_free(check_uses_git())
})

test_that("git_has_commit() changes after first commit", {
  skip_if_no_git_user()

  create_local_package()
  git_init()

  expect_false(git_has_commits())

  git_commit("DESCRIPTION", "test")
  expect_true(git_has_commits())
})
