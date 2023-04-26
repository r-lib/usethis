test_that("use_github_links populates empty URL field", {
  create_local_package()
  use_git()
  local_mocked_bindings(
    gh_tr = function(tr) {
        function(endpoint, ...) list(html_url = "https://github.com/USER/REPO")
      },
    target_repo = function(github_get) NULL
  )

  # when no URL field
  use_github_links()
  expect_equal(proj_desc()$get_urls(), "https://github.com/USER/REPO")
})

test_that("use_github_links overwrites field when overwrite = TRUE", {
  create_local_package()
  use_git()
  local_mocked_bindings(
    gh_tr = function(tr) {
        function(endpoint, ...) list(html_url = "https://github.com/USER/REPO")
      },
    target_repo = function(github_get) NULL
  )
  # when an existing url, and overwrite = TRUE, should overwrite with repo URL
  use_description_field("URL", "https://existing.url", overwrite = TRUE)
  use_github_links(overwrite = TRUE)
  expect_equal(proj_desc()$get_urls(), "https://github.com/USER/REPO")
})

test_that("use_github_links appends to URL field when overwrite = FALSE", {
  create_local_package()
  use_git()
  local_mocked_bindings(
    gh_tr = function(tr) {
        function(endpoint, ...) list(html_url = "https://github.com/USER/REPO")
      },
    target_repo = function(github_get) NULL
  )
  # when an existing field, and overwrite = FALSE, should append
  use_description_field("URL", "https://existing.url", overwrite = TRUE)
  use_github_links(overwrite = FALSE)
  expect_equal(proj_desc()$get_urls(),
               c("https://existing.url", "https://github.com/USER/REPO"))
})
