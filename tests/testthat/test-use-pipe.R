context("use_pipe")

test_that("use_pipe() requires a package", {
  scoped_temporary_project()
  expect_error(use_pipe(), "not an R package")
})

test_that("use_pipe() adds promised file, Imports magrittr", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE, {
      scoped_temporary_package()
      use_pipe()
      expect_match(desc::desc_get("Imports", proj_get()), "magrittr")
      expect_proj_file("R", "utils-pipe.R")
    }
  )
})
