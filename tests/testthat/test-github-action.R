test_that("use_github_action() allows for custom urls", {
  skip_if_no_git_user()

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")

  # Directly call to r-lib actions
  use_github_action(url = "https://raw.githubusercontent.com/r-lib/actions/master/examples/check-full.yaml")
  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/check-full.yaml")
})

test_that("use_github_action() appends yaml in name if missing", {
  skip_if_no_git_user()

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")

  # Directly call to r-lib actions
  use_github_action("check-full")
  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/check-full.yaml")
})
