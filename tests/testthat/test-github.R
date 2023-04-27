test_that("use_github_links populates empty URL field", {
  local_interactive(FALSE)
  create_local_package()
  use_git()
  skip_if_no_git_user()

  local_mocked_bindings(
    gh_tr = function(tr) {
        function(endpoint, ...) list(html_url = "https://github.com/OWNER/REPO")
      },
    target_repo = function(github_get) NULL
  )

  # when no URL field
  use_github_links()
  expect_equal(proj_desc()$get_urls(), "https://github.com/OWNER/REPO")
  expect_equal(
    proj_desc()$get_field("BugReports"),
    "https://github.com/OWNER/REPO/issues"
    )
})

test_that("use_github_links errors when overwrite = FALSE and existing urls", {
  local_interactive(FALSE)
  create_local_package()

  use_git()
  skip_if_no_git_user()
  local_mocked_bindings(
    gh_tr = function(tr) {
      function(endpoint, ...) list(html_url = "https://github.com/OWNER/REPO")
    },
    target_repo = function(github_get) NULL
  )

  d <- proj_desc()
  d$set_urls("https://existing.url")
  d$write()

  expect_snapshot(use_github_links(overwrite = FALSE), error = TRUE)
})

test_that("use_github_links appends to URL field when overwrite = TRUE", {
  local_interactive(FALSE)
  create_local_package()
  use_git()
  skip_if_no_git_user()

  local_mocked_bindings(
    gh_tr = function(tr) {
        function(endpoint, ...) list(html_url = "https://github.com/OWNER/REPO")
      },
    target_repo = function(github_get) NULL
  )

  # when an existing field, and overwrite = TRUE, should append
  d <- proj_desc()
  d$set_urls(c("https://existing.url", "https://existing.url1"))
  d$write()

  use_github_links(overwrite = TRUE)
  expect_equal(
    proj_desc()$get_urls(),
    c("https://existing.url", "https://existing.url1",
      "https://github.com/OWNER/REPO")
  )
})
