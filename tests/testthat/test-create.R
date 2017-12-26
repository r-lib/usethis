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
