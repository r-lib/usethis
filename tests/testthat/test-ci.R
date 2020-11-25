test_that("use_circleci() configures CircleCI", {
  skip_if_no_git_user()

  local_interactive(FALSE)
  create_local_package()
  use_git()

  with_mock(
    target_repo_spec = function(...) "OWNER/REPO",
    use_circleci(browse = FALSE)
  )

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

  dir_delete(proj_path(".circleci"))
  docker <- "rocker/r-ver:3.5.3"
  with_mock(
    target_repo_spec = function(...) "OWNER/REPO",
    use_circleci(browse = FALSE, image = docker)
  )
  yml <- yaml::yaml.load_file(proj_path(".circleci", "config.yml"))
  expect_identical(yml$jobs$build$docker[[1]]$image, docker)
})
