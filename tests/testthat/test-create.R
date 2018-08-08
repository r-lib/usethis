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

test_that("nested package is disallowed, by default", {
  dir <- scoped_temporary_package()
  expect_error(scoped_temporary_package(path(dir, "abcde")), "nested")
})

test_that("nested project is disallowed, by default", {
  dir <- scoped_temporary_project()
  expect_error(scoped_temporary_project(path(dir, "abcde")), "nested")
})

## https://github.com/r-lib/usethis/issues/227
test_that("create_* works w/ non-existing rel path and absolutizes it", {
  ## take care to provide a **non-absolute** path
  path_package <- path_file(file_temp(pattern = "aaa"))
  withr::with_dir(
    path_temp(), {
      old_project <- proj$cur
      create_package(path_package, rstudio = FALSE, open = FALSE)
      new_proj <- proj_get()
      proj_set(old_project, force = TRUE, quiet = TRUE)
    }
  )
  expect_true(dir_exists(new_proj))

  path_project <- path_file(file_temp(pattern = "aaa"))
  withr::with_dir(
    path_temp(), {
      old_project <- proj$cur
      create_project(path_project, rstudio = FALSE, open = FALSE)
      new_proj <- proj_get()
      proj_set(old_project, force = TRUE, quiet = TRUE)
    }
  )
  expect_true(dir_exists(new_proj))
})

test_that("rationalize_fork() honors fork = FALSE", {
  expect_false(
    rationalize_fork(fork = FALSE, repo_info = list(), pat_available = TRUE)
  )
  expect_false(
    rationalize_fork(fork = FALSE, repo_info = list(), pat_available = FALSE)
  )
})

test_that("rationalize_fork() won't attempt to fork w/o PAT", {
  expect_false(
    rationalize_fork(fork = NA, repo_info = list(), pat_available = FALSE)
  )
  expect_error(
    rationalize_fork(fork = TRUE, repo_info = list(), pat_available = FALSE),
    "No GitHub .+auth_token.+"
  )
})

test_that("rationalize_fork() won't attempt to fork repo owned by user", {
  expect_error(
    rationalize_fork(
      fork = TRUE,
      repo_info = list(full_name = "USER/REPO", owner = list(login = "USER")),
      pat_available = TRUE,
      user = "USER"
    ),
    "Can't fork"
  )
})

test_that("rationalize_fork() forks by default iff user cannot push", {
  expect_false(
    rationalize_fork(
      fork = NA,
      repo_info = list(permissions = list(push = TRUE)),
      pat_available = TRUE
    )
  )
  expect_true(
    rationalize_fork(
      fork = NA,
      repo_info = list(
        owner = list(login = "SOMEONE_ELSE"),
        permissions = list(push = FALSE)
      ),
      pat_available = TRUE
    )
  )
})
