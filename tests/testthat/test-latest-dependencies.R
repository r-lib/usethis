test_that("use_tidy_versions() specifies a version for dependencies", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org")))

  create_local_package()
  use_package("usethis")
  use_package("desc")
  use_latest_dependencies()

  deps <- proj_deps()
  expect_equal(
    deps$version[deps$package %in% c("usethis", "desc")] == "*",
    c(FALSE, FALSE)
  )
})

test_that("use_tidy_versions() doesn't affect suggests", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org")))

  create_local_package()
  use_package("cli", "Suggests")

  deps <- proj_deps()
  expect_equal(deps$version[deps$package == "cli"], "*")
})

test_that("use_tidy_versions() does nothing for a base package", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org")))

  ## if we ever depend on a recommended package, could beef up this test a bit
  create_local_package()
  use_package("tools")
  use_latest_dependencies()

  deps <- proj_deps()
  expect_equal(deps$version[deps$package == "tools"], "*")
})

