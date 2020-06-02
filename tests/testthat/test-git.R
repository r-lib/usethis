test_that("git_has_commit() changes after first commit", {
  skip_if_no_git_user()

  create_local_package()
  git_init()

  expect_true(uses_git())
  expect_false(git_has_commits())

  git_commit("DESCRIPTION", "test")
  expect_true(git_has_commits())
})
