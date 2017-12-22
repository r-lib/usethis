context("rstudio")

test_that("use_rstudio() creates .Rproj file, named after directory", {
  dir <- scoped_temporary_package(rstudio = FALSE)
  capture_output(use_rstudio())
  rproj <- list.files(proj_get(), pattern = "\\.Rproj$")
  expect_identical(rproj, paste0(basename(dir), ".Rproj"))
})

test_that("a non-RStudio project is recognized", {
  scoped_temporary_package(rstudio = FALSE)
  expect_false(is_rstudio_project())
  expect_identical(rproj_path(), NA_character_)
})

test_that("an RStudio project is recognized", {
  scoped_temporary_package(rstudio = TRUE)
  expect_true(is_rstudio_project())
  expect_match(rproj_path(), "\\.Rproj$")
})

test_that("we error for multiple Rproj files", {
  scoped_temporary_package(rstudio = TRUE)
  file.copy(
    file.path(proj_get(), rproj_path()),
    file.path(proj_get(), "copy.Rproj")
  )
  expect_error(rproj_path(), "Multiple .Rproj files found", fixed = TRUE)
})
