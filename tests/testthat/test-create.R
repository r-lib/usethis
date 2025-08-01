test_that("create_package() creates a package", {
  dir <- create_local_package()
  expect_true(possibly_in_proj(dir))
  expect_true(is_package(dir))
})

test_that("create_project() creates a non-package project", {
  dir <- create_local_project()
  expect_true(possibly_in_proj(dir))
  expect_false(is_package(dir))
})

test_that("create_*(open = FALSE) returns path to new proj, restores active proj", {
  path <- file_temp()
  cur_proj <- proj_get_()

  out_path <- create_package(path, open = FALSE)
  expect_equal(proj_get_(), cur_proj)
  expect_equal(proj_path_prep(path), out_path)
  dir_delete(out_path)

  out_path <- create_project(path, open = FALSE)
  expect_equal(proj_get_(), cur_proj)
  expect_equal(proj_path_prep(path), out_path)
  dir_delete(out_path)
})

test_that("nested package is disallowed, by default", {
  dir <- create_local_package()
  expect_usethis_error(create_package(path(dir, "abcde")), "anyway")
})

test_that("nested project is disallowed, by default", {
  dir <- create_local_project()
  expect_usethis_error(create_project(path(dir, "abcde")), "anyway")
})

test_that("nested package can be created if user really, really wants to", {
  parent <- create_local_package()
  child_path <- path(parent, "fghijk")

  # since user can't approve interactively, use the backdoor
  withr::local_options("usethis.allow_nested_project" = TRUE)

  child_result <- create_package(child_path)

  expect_equal(child_path, child_result)
  expect_true(possibly_in_proj(child_path))
  expect_true(is_package(child_path))
  expect_equal(project_name(child_path), "fghijk")
})

test_that("nested project can be created if user really, really wants to", {
  parent <- create_local_project()
  child_path <- path(parent, "fghijk")

  # since user can't approve interactively, use the backdoor
  withr::local_options("usethis.allow_nested_project" = TRUE)

  child_result <- create_project(child_path)

  expect_equal(child_path, child_result)
  expect_true(possibly_in_proj(child_path))
  expect_equal(project_name(child_path), "fghijk")
})

test_that("can create package in current directory (literally in '.')", {
  target_path <- dir_create(file_temp("mypackage"))
  withr::defer(dir_delete(target_path))
  withr::local_dir(target_path)
  orig_proj <- proj_get_()
  orig_wd <- path_wd()

  expect_no_error(
    out_path <- create_package(".", open = FALSE)
  )
  expect_equal(path_wd(), orig_wd)
  expect_equal(proj_get_(), orig_proj)
})

## https://github.com/r-lib/usethis/issues/227
test_that("create_* works w/ non-existing rel path, open = FALSE case", {
  sandbox <- path_real(dir_create(file_temp("sandbox")))
  orig_proj <- proj_get_()
  orig_wd <- path_wd()
  withr::defer(dir_delete(sandbox))
  withr::defer(proj_set(orig_proj, force = TRUE))
  withr::local_dir(sandbox)

  rel_path_pkg <- path_file(file_temp(pattern = "abc"))
  expect_no_error(
    out_path <- create_package(rel_path_pkg, open = FALSE)
  )
  expect_true(dir_exists(rel_path_pkg))
  expect_equal(out_path, proj_path_prep(rel_path_pkg))
  expect_equal(proj_get_(), orig_proj)
  expect_equal(path_wd(), sandbox)

  rel_path_proj <- path_file(file_temp(pattern = "def"))
  expect_no_error(
    out_path <- create_project(rel_path_proj, open = FALSE)
  )
  expect_true(dir_exists(rel_path_proj))
  expect_equal(out_path, proj_path_prep(rel_path_proj))
  expect_equal(proj_get_(), orig_proj)
  expect_equal(path_wd(), sandbox)
})

# https://github.com/r-lib/usethis/issues/1122
test_that("create_*() works w/ non-existing rel path, open = TRUE, not in RStudio", {
  sandbox <- path_real(dir_create(file_temp("sandbox")))
  orig_proj <- proj_get_()
  withr::defer(dir_delete(sandbox))
  withr::defer(proj_set(orig_proj, force = TRUE))
  withr::local_dir(sandbox)
  local_rstudio_available(FALSE)

  # package
  rel_path_pkg <- path_file(file_temp(pattern = "ghi"))
  expect_no_error(
    out_path <- create_package(rel_path_pkg, open = TRUE)
  )
  exp_path_pkg <- path(sandbox, rel_path_pkg)
  expect_equal(out_path, exp_path_pkg)
  expect_equal(path_wd(), out_path)
  expect_equal(proj_get(), out_path)

  setwd(sandbox)

  # project
  rel_path_proj <- path_file(file_temp(pattern = "jkl"))
  expect_no_error(
    out_path <- create_project(rel_path_proj, open = TRUE)
  )
  exp_path_proj <- path(sandbox, rel_path_proj)
  expect_equal(out_path, exp_path_proj)
  expect_equal(path_wd(), out_path)
  expect_equal(proj_get(), out_path)
})

test_that("we discourage project creation in home directory", {
  local_interactive(FALSE)
  expect_usethis_error(create_package(path_home()), "create anyway")
  expect_usethis_error(create_project(path_home()), "create anyway")

  if (is_windows()) {
    expect_usethis_error(create_package(path_home_r()), "create anyway")
    expect_usethis_error(create_project(path_home_r()), "create anyway")
  }
})

test_that("create_quarto_project() works for basic usage", {
  skip_if_not_installed("quarto")

  dir <- create_local_quarto_project()
  expect_proj_file("_quarto.yml")
  expect_true(possibly_in_proj(dir))
})
