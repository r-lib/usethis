context("use_circleci")

test_that("uses_circleci() reports usage of CircleCI", {
  scoped_temporary_package()
  expect_false(uses_circleci())
  use_git()
  git2r::remote_add(name = "origin", url = "https://github.com/fake/fake")
  use_circleci(browse = FALSE)
  expect_true(uses_circleci())
})

test_that("check_uses_circleci() can throw error", {
  scoped_temporary_package()
  expect_error(check_uses_circleci(),
               "Do you need to run `use_circleci\\(\\)`")
})

test_that("use_circleci() configures CircleCI", {
  scoped_temporary_package()
  use_git()
  git2r::remote_add(name = "origin", url = "https://github.com/fake/fake")
  use_circleci(browse = FALSE)
  expect_proj_dir(".circleci")
  expect_proj_file(".circleci/config.yml")
  yml <- yaml::yaml.load_file(".circleci/config.yml")
  expect_identical(yml$jobs$build$steps[[6]]$store_artifacts$path,
                   paste0(project_name(), ".Rcheck/"))
})

test_that("use_circleci() specifies Docker image", {
  scoped_temporary_package()
  use_git()
  git2r::remote_add(name = "origin", url = "https://github.com/fake/fake")
  docker <- "rocker/r-ver:3.5.3"
  use_circleci(browse = FALSE, image = docker)
  yml <- yaml::yaml.load_file(".circleci/config.yml")
  expect_identical(yml$jobs$build$docker[[1]]$image, docker)
})
