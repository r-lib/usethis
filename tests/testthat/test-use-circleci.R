context("use_circleci")

test_that("check_uses_circleci() can throw error", {
  create_local_package()
  expect_error(
    check_uses_circleci(),
    "Do you need to run `use_circleci()`?",
    fixed = TRUE, class = "usethis_error"
  )
})

test_that("use_circleci() configures CircleCI", {
  skip_if_no_git_user()

  create_local_package()
  use_git()

  with_mock(
    `usethis:::get_github_primary` = function() {
      list(repo_spec = "OWNER/REPO", can_push = TRUE, repo_owner = "OWNER")
    },
    use_circleci(browse = FALSE)
  )

  expect_true(uses_circleci())
  expect_true(is_build_ignored("^\\.circleci$"))

  expect_proj_dir(".circleci")
  expect_proj_file(".circleci/config.yml")
  yml <- yaml::yaml.load_file(proj_path(".circleci", "config.yml"))
  expect_identical(
    yml$jobs$build$steps[[7]]$store_artifacts$path,
    paste0(project_name(), ".Rcheck/")
  )

  # use_circleci() properly formats keys for cache
  expect_identical(
    yml$jobs$build$steps[[1]]$restore_cache$keys,
    c("r-pkg-cache-{{ arch }}-{{ .Branch }}", "r-pkg-cache-{{ arch }}-")
  )
  expect_identical(
    yml$jobs$build$steps[[8]]$save_cache$key,
    "r-pkg-cache-{{ arch }}-{{ .Branch }}"
  )

  docker <- "rocker/r-ver:3.5.3"
  with_mock(
    `usethis:::get_github_primary` = function() {
      list(repo_spec = "OWNER/REPO", can_push = TRUE, repo_owner = "OWNER")
    },
    can_overwrite = function(path) TRUE,
    use_circleci(browse = FALSE, image = docker)
  )
  yml <- yaml::yaml.load_file(proj_path(".circleci", "config.yml"))
  expect_identical(yml$jobs$build$docker[[1]]$image, docker)
})
