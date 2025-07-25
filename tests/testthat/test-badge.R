test_that("use_[cran|bioc]_badge() don't error", {
  create_local_package()
  expect_no_error(use_cran_badge())
  expect_no_error(use_bioc_badge())
})

test_that("use_lifecycle_badge() handles bad and good input", {
  create_local_package()

  expect_snapshot(error = TRUE, {
    use_lifecycle_badge("eperimental")
  })

  expect_no_error(use_lifecycle_badge("stable"))
})

test_that("use_binder_badge() needs a github repository", {
  skip_if_no_git_user()
  create_local_project()
  use_git()
  expect_error(
    use_binder_badge(),
    class = "usethis_error_bad_github_remote_config"
  )
})

test_that("use_r_universe_badge() needs a repository", {
  skip_if_no_git_user()
  create_local_package()
  use_git()
  expect_snapshot(
    error = TRUE,
    use_r_universe_badge(),
    transform = scrub_testpkg
  )
})

test_that("use_posit_cloud_badge() handles bad and good input", {
  create_local_project()
  expect_snapshot(use_posit_cloud_badge(), error = TRUE)
  expect_snapshot(use_posit_cloud_badge(123), error = TRUE)
  expect_snapshot(use_posit_cloud_badge("http://posit.cloud/123"), error = TRUE)
  expect_no_error(use_posit_cloud_badge("https://posit.cloud/content/123"))
  expect_no_error(use_posit_cloud_badge(
    "https://posit.cloud/spaces/123/content/123"
  ))
})

test_that("use_badge() does nothing if badge seems to pre-exist", {
  create_local_package()
  href <- "https://cran.r-project.org/package=foo"
  writeLines(href, proj_path("README.md"))
  expect_false(use_badge("foo", href, "SRC"))
})
