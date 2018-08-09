context("projects")

test_that("proj_set() errors on non-existent path", {
  expect_error(
    proj_set("abcedefgihklmnopqrstuv"),
    "Directory does not exist"
  )
})

test_that("proj_set() errors if no criteria are fulfilled", {
  tmpdir <- file_temp(pattern = "i-am-not-a-project")
  on.exit(dir_delete(tmpdir))
  dir_create(tmpdir)
  expect_error(
    proj_set(tmpdir),
    "does not appear to be inside a project or package"
  )
})

test_that("proj_set() can be forced, even if no criteria are fulfilled", {
  tmpdir <- file_temp(pattern = "i-am-not-a-project")
  on.exit(dir_delete(tmpdir))
  dir_create(tmpdir)
  expect_error_free(proj_set(tmpdir, force = TRUE, quiet = TRUE))
  expect_identical(proj_get(), path_real(tmpdir))
  expect_error(
    proj_set(proj_get()),
    "does not appear to be inside a project or package"
  )
})

test_that("is_package() detects package-hood", {
  scoped_temporary_package()
  expect_true(is_package())

  scoped_temporary_project()
  expect_false(is_package())
})

test_that("check_is_package() errors for non-package", {
  scoped_temporary_project()
  expect_error(check_is_package(), "not an R package")
})

test_that("check_is_package() can reveal who's asking", {
  scoped_temporary_project()
  expect_error(check_is_package("foo"), "foo")
})

test_that("proj_path() appends to the project path", {
  scoped_temporary_project()
  expect_equal(
    proj_path("a", "b", "c"),
    path(proj_get(), "a/b/c")
  )
  expect_identical(proj_path("a", "b", "c"), proj_path("a/b/c"))
})

test_that("proj_rel_path() returns path part below the project", {
  scoped_temporary_project()
  expect_equal(proj_rel_path(proj_path("a/b/c")), "a/b/c")
})

test_that("proj_rel_path() returns path 'as is' if not in project", {
  scoped_temporary_project()
  expect_identical(proj_rel_path(path_temp()), path_temp())
})

test_that("proj_set() enforces proj path preparation policy", {
  ## specifically: check that proj_get() returns realized path
  t <- dir_create(file_temp())

  ## a/b/d and a/b2/d identify same directory
  a <- path_real(dir_create(path(t, "a")))
  b <- dir_create(path(a, "b"))
  b2 <- link_create(b, path(a, "b2"))
  d <- dir_create(path(b, "d"))

  ## input path includes symbolic link
  path_with_symlinks <- path(b2, "d")
  expect_equal(path_rel(path_with_symlinks, a), "b2/d")

  ## force = TRUE
  proj_set(path_with_symlinks, force = TRUE, quiet = TRUE)
  expect_equal(path_rel(proj_get(), a), "b/d")

  ## force = FALSE
  file_create(path(b, "d", ".here"))
  proj_set(path_with_symlinks, force = FALSE, quiet = TRUE)
  expect_equal(path_rel(proj_get(), a), "b/d")

  dir_delete(t)
})

test_that("proj_path_prep() passes NULL through", {
  expect_null(proj_path_prep(NULL))
})

test_that("is_in_proj() detects whether files are (or would be) in project", {
  scoped_temporary_package()

  ## file does not exist but would be in project if created
  expect_true(is_in_proj(proj_path("fiction")))

  ## file exists in project
  expect_true(is_in_proj(proj_path("DESCRIPTION")))

  ## file does not exist and would not be in project if created
  expect_false(is_in_proj(file_temp()))

  ## file exists and is not in project
  expect_false(is_in_proj(path_temp()))
})

test_that("proj_sitrep() reports current working/project state", {
  pkg <- scoped_temporary_package()
  x <- proj_sitrep()
  expect_s3_class(x, "sitrep")
  expect_false(is.null(x[["working_directory"]]))
  expect_identical(
    fs::path_file(pkg),
    fs::path_file(x[["active_usethis_proj"]])
  )
})
