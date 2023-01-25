test_that("sets version for imports & depends dependencies", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org")))

  create_local_package()
  use_package("usethis")
  use_package("desc", "Depends")
  use_latest_dependencies()

  deps <- proj_deps()
  expect_equal(
    deps$version[deps$package %in% c("usethis", "desc")] == "*",
    c(FALSE, FALSE)
  )
})

test_that("doesn't affect suggests", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org")))

  create_local_package()
  use_package("cli", "Suggests")
  use_latest_dependencies()

  deps <- proj_deps()
  expect_equal(deps$version[deps$package == "cli"], "*")
})

test_that("does nothing for a base package", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org")))

  create_local_package()
  use_package("tools") # base
  use_package("Matrix") # recommended
  use_latest_dependencies()

  deps <- proj_deps()
  expect_equal(
    deps$version[deps$package %in% c("tools", "Matrix")],
    c("*", "*")
  )
})

