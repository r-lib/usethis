test_that("has_github_links() uses the target_repo, if provided", {
  skip_if_no_git_user()
  create_local_package()
  local_interactive(FALSE)
  use_git()

  desc::desc_set_urls("https://github.com/OWNER/REPO")
  desc::desc_set("BugReports", "https://github.com/OWNER/REPO/issues")

  tr <- list(url = "git@github.com:OWNER/REPO.git")

  expect_true(has_github_links(tr))
})

test_that("use_github_links populates empty URL field", {
  skip_if_no_git_user()
  local_interactive(FALSE)
  create_local_package()
  use_git()

  local_mocked_bindings(
    github_url_from_git_remotes = function() "https://github.com/OWNER/REPO"
  )

  # when no URL field
  use_github_links()
  expect_equal(proj_desc()$get_urls(), "https://github.com/OWNER/REPO")
  expect_equal(
    proj_desc()$get_field("BugReports"),
    "https://github.com/OWNER/REPO/issues"
  )
})

test_that("use_github_links() aborts or appends URLs when it should", {
  skip_if_no_git_user()
  local_interactive(FALSE)
  create_local_package()
  use_git()

  local_mocked_bindings(
    github_url_from_git_remotes = function() "https://github.com/OWNER/REPO"
  )

  d <- proj_desc()
  d$set_urls(c("https://existing.url", "https://existing.url1"))
  d$write()

  expect_snapshot(use_github_links(overwrite = FALSE), error = TRUE)

  use_github_links(overwrite = TRUE)
  expect_equal(
    proj_desc()$get_urls(),
    c(
      "https://existing.url",
      "https://existing.url1",
      "https://github.com/OWNER/REPO"
    )
  )
})
