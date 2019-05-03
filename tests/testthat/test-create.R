context("create")

test_that("create_package() creates a package", {
  dir <- scoped_temporary_package()
  expect_true(possibly_in_proj(dir))
  expect_true(is_package(dir))
})

test_that("create_project() creates a non-package project", {
  dir <- scoped_temporary_project()
  expect_true(possibly_in_proj(dir))
  expect_false(is_package(dir))
})

test_that("create functions return path to new proj, but restore active proj", {
  path <- file_temp()
  cur_proj <- proj_get()

  new_path <- create_package(path)
  expect_equal(proj_get(), cur_proj)
  expect_equal(proj_path_prep(path), new_path)
  dir_delete(path)

  new_path <- create_project(path)
  expect_equal(proj_get(), cur_proj)
  expect_equal(proj_path_prep(path), new_path)
  dir_delete(path)
})

test_that("nested package is disallowed, by default", {
  dir <- scoped_temporary_package()
  expect_usethis_error(scoped_temporary_package(path(dir, "abcde")), "anyway")
})

test_that("nested project is disallowed, by default", {
  dir <- scoped_temporary_project()
  expect_usethis_error(scoped_temporary_project(path(dir, "abcde")), "anyway")
})

## https://github.com/r-lib/usethis/issues/227
test_that("create_* works w/ non-existing rel path and absolutizes it", {
  ## take care to provide a **non-absolute** path
  path_package <- path_file(file_temp(pattern = "aaa"))
  withr::with_dir(
    path_temp(),
    create_package(path_package, rstudio = FALSE, open = FALSE)
  )
  expect_true(dir_exists(path_temp(path_package)))

  path_project <- path_file(file_temp(pattern = "aaa"))
  withr::with_dir(
    path_temp(),
    create_project(path_project, rstudio = FALSE, open = FALSE)
  )
  expect_true(dir_exists(path_temp(path_project)))
})

test_that("rationalize_fork() honors fork = FALSE", {
  expect_false(
    rationalize_fork(fork = FALSE, repo_info = list(), auth_token = "PAT")
  )
  expect_false(
    rationalize_fork(fork = FALSE, repo_info = list(), auth_token = "")
  )
})

test_that("rationalize_fork() won't attempt to fork w/o auth_token", {
  expect_false(
    rationalize_fork(fork = NA, repo_info = list(), auth_token = "")
  )
  expect_usethis_error(
    rationalize_fork(fork = TRUE, repo_info = list(), auth_token = ""),
    "No GitHub .+auth_token.+ is available"
  )
})

test_that("rationalize_fork() won't attempt to fork repo owned by user", {
  with_mock(
    `usethis:::github_user` = function(auth_token) list(login = "USER"),
    expect_usethis_error(
      rationalize_fork(
        fork = TRUE,
        repo_info = list(full_name = "USER/REPO", owner = list(login = "USER")),
        auth_token = "PAT"
      ),
      "Can't fork"
    )
  )
})

test_that("rationalize_fork() forks by default iff user cannot push", {
  expect_false(
    rationalize_fork(
      fork = NA,
      repo_info = list(permissions = list(push = TRUE)),
      auth_token = ""
    )
  )
  expect_true(
    rationalize_fork(
      fork = NA,
      repo_info = list(
        owner = list(login = "SOMEONE_ELSE"),
        permissions = list(push = FALSE)
      ),
      auth_token = "PAT"
    )
  )
})
