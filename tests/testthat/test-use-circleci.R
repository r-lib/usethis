context("use_circleci")

test_that("uses_circleci() reports usage of CircleCI", {
  skip_if_no_git_config()

  scoped_temporary_package()
  expect_false(uses_circleci())
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")
  use_circleci(browse = FALSE)
  expect_true(uses_circleci())
})

test_that("check_uses_circleci() can throw error", {
  scoped_temporary_package()
  expect_error(
    check_uses_circleci(),
    "Do you need to run `use_circleci()`?",
    fixed = TRUE, class = "usethis_error"
  )
})

test_that("use_circleci() configures CircleCI", {
  skip_if_no_git_config()

  scoped_temporary_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")
  use_circleci(browse = FALSE)
  expect_proj_dir(".circleci")
  expect_proj_file(".circleci/config.yml")
  yml <- yaml::yaml.load_file(".circleci/config.yml")
  expect_identical(
    yml$jobs$build$steps[[7]]$store_artifacts$path,
    paste0(project_name(), ".Rcheck/")
  )
})

test_that("use_circleci() specifies Docker image", {
  skip_if_no_git_config()

  scoped_temporary_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")
  docker <- "rocker/r-ver:3.5.3"
  use_circleci(browse = FALSE, image = docker)
  yml <- yaml::yaml.load_file(".circleci/config.yml")
  expect_identical(yml$jobs$build$docker[[1]]$image, docker)
})
