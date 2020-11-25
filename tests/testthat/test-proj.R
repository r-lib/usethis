test_that("proj_set() errors on non-existent path", {
  expect_usethis_error(
    proj_set("abcedefgihklmnopqrstuv"),
    "does not exist"
  )
})

test_that("proj_set() errors if no criteria are fulfilled", {
  tmpdir <- withr::local_tempdir(pattern = "i-am-not-a-project")
  expect_usethis_error(
    proj_set(tmpdir),
    "does not appear to be inside a project or package"
  )
})

test_that("proj_set() can be forced, even if no criteria are fulfilled", {
  tmpdir <- withr::local_tempdir(pattern = "i-am-not-a-project")

  expect_error_free(old <- proj_set(tmpdir, force = TRUE))
  withr::defer(proj_set(old))
  expect_identical(proj_get(), proj_path_prep(tmpdir))
})

test_that("is_package() detects package-hood", {
  create_local_package()
  expect_true(is_package())

  create_local_project()
  expect_false(is_package())
})

test_that("check_is_package() errors for non-package", {
  create_local_project()
  expect_usethis_error(check_is_package(), "not an R package")
})

test_that("check_is_package() can reveal who's asking", {
  create_local_project()
  expect_usethis_error(check_is_package("foo"), "foo")
})

test_that("proj_path() appends to the project path", {
  create_local_project()
  expect_equal(
    proj_path("a", "b", "c"),
    path(proj_get(), "a/b/c")
  )
  expect_identical(proj_path("a", "b", "c"), proj_path("a/b/c"))
})

test_that("proj_rel_path() returns path part below the project", {
  create_local_project()
  expect_equal(proj_rel_path(proj_path("a/b/c")), "a/b/c")
})

test_that("proj_rel_path() returns path 'as is' if not in project", {
  create_local_project()
  expect_identical(proj_rel_path(path_temp()), path_temp())
})

test_that("proj_set() enforces proj path preparation policy", {
  # specifically: check that proj_get() returns realized path
  t <- withr::local_tempdir("proj-set-path-prep")

  # a/b/d and a/b2/d identify same directory
  a <- path_real(dir_create(path(t, "a")))
  b <- dir_create(path(a, "b"))
  b2 <- link_create(b, path(a, "b2"))
  d <- dir_create(path(b, "d"))

  # input path includes symbolic link
  path_with_symlinks <- path(b2, "d")
  expect_equal(path_rel(path_with_symlinks, a), path("b2/d"))

  # force = TRUE
  local_project(path_with_symlinks, force = TRUE)
  expect_equal(path_rel(proj_get(), a), path("b/d"))

  # force = FALSE
  file_create(path(b, "d", ".here"))
  proj_set(path_with_symlinks, force = FALSE)
  expect_equal(path_rel(proj_get(), a), path("b/d"))
})

test_that("proj_path_prep() passes NULL through", {
  expect_null(proj_path_prep(NULL))
})

test_that("is_in_proj() detects whether files are (or would be) in project", {
  create_local_package()

  ## file does not exist but would be in project if created
  expect_true(is_in_proj(proj_path("fiction")))

  ## file exists in project
  expect_true(is_in_proj(proj_path("DESCRIPTION")))

  ## file does not exist and would not be in project if created
  expect_false(is_in_proj(file_temp()))

  ## file exists and is not in project
  expect_false(is_in_proj(path_temp()))
})

test_that("is_in_proj() does not activate a project", {
  pkg <- create_local_package()
  path <- proj_path("DESCRIPTION")
  expect_true(is_in_proj(path))
  local_project(NULL)
  expect_false(is_in_proj(path))
  expect_false(proj_active())
})

test_that("proj_sitrep() reports current working/project state", {
  pkg <- create_local_package()
  x <- proj_sitrep()
  expect_s3_class(x, "sitrep")
  expect_false(is.null(x[["working_directory"]]))
  expect_identical(
    fs::path_file(pkg),
    fs::path_file(x[["active_usethis_proj"]])
  )
})

test_that("with_project() runs code in temp proj, restores (lack of) proj", {
  old_project <- proj_get_()
  withr::defer(proj_set_(old_project))

  temp_proj <- create_project(
    file_temp(pattern = "TEMPPROJ"),
    rstudio = FALSE, open = FALSE
  )

  proj_set_(NULL)
  expect_identical(proj_get_(), NULL)

  res <- with_project(path = temp_proj, proj_get_())

  expect_identical(res, temp_proj)
  expect_identical(proj_get_(), NULL)
})

test_that("with_project() runs code in temp proj, restores original proj", {
  old_project <- proj_get_()
  withr::defer(proj_set_(old_project))

  host <- create_project(
    file_temp(pattern = "host"),
    rstudio = FALSE, open = FALSE
  )
  guest <- create_project(
    file_temp(pattern = "guest"),
    rstudio = FALSE, open = FALSE
  )

  proj_set(host)
  expect_identical(proj_get_(), host)

  res <- with_project(path = guest, proj_get_())

  expect_identical(res, guest)
  expect_identical(proj_get(), host)
})

test_that("with_project() works when temp proj == original proj", {
  old_project <- proj_get_()
  withr::defer(proj_set_(old_project))

  host <- create_project(
    file_temp(pattern = "host"),
    rstudio = FALSE, open = FALSE
  )

  proj_set(host)
  expect_identical(proj_get_(), host)

  res <- with_project(path = host, proj_get_())

  expect_identical(res, host)
  expect_identical(proj_get(), host)
})

test_that("local_project() activates proj til scope ends", {
  old_project <- proj_get_()
  withr::defer(proj_set_(old_project))

  new_proj <- file_temp(pattern = "localprojtest")
  create_project(new_proj, rstudio = FALSE, open = FALSE)
  proj_set_(NULL)

  foo <- function() {
    local_project(new_proj)
    proj_sitrep()
  }
  res <- foo()

  expect_identical(
    res[["active_usethis_proj"]],
    as.character(proj_path_prep(new_proj))
  )
  expect_null(proj_get_())
})

# https://github.com/r-lib/usethis/issues/954
test_that("proj_activate() works with relative path when RStudio is not detected", {
  sandbox <- path_real(dir_create(file_temp("sandbox")))
  withr::defer(dir_delete(sandbox))
  orig_proj <- proj_get_()
  withr::defer(proj_set(orig_proj, force = TRUE))
  withr::local_dir(sandbox)

  rel_path_proj <- path_file(file_temp(pattern = "mno"))
  out_path <- create_project(rel_path_proj, rstudio = FALSE, open = FALSE)
  with_mock(
    # make sure we act as if not in RStudio
    rstudio_available = function(...) FALSE,
    expect_error_free(
      result <- proj_activate(rel_path_proj)
    )
  )
  expect_true(result)
  expect_equal(path_wd(), out_path)
  expect_equal(proj_get(), out_path)
})
