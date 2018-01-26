context("create")

test_that("create_package() creates a package", {
  dir <- scoped_temporary_package()
  expect_true(is_proj(dir))
  expect_true(is_package(dir))
})

test_that("create_project() creates a non-package project", {
  dir <- scoped_temporary_project()
  expect_true(is_proj(dir))
  expect_false(is_package(dir))
})

test_that("nested package is disallowed, by default", {
  dir <- scoped_temporary_package()
  expect_error(scoped_temporary_package(file.path(dir, "man")), "nested")
})

test_that("nested project is disallowed, by default", {
  dir <- scoped_temporary_project()
  subdir <- create_directory(dir, "subdir")
  expect_error(scoped_temporary_project(subdir), "nested")
})

## https://github.com/r-lib/usethis/issues/227
test_that("proj is normalized when path does not pre-exist", {
  ## take care to provide a **non-absolute** path
  path <- basename(tempfile())
  withr::with_dir(
    tempdir(), {
      old_proj <- proj_get()
      capture_output(create_package(path, rstudio = FALSE, open = FALSE))
      new_proj <- proj_get()
      proj_set(old_proj)
    }
  )
  expect_true(dir.exists(new_proj))
})
