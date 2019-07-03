context("use_pipe")

test_that("use_pipe() requires a package", {
  scoped_temporary_project()
  expect_usethis_error(use_pipe(), "not an R package")
})

test_that("use_pipe(export = TRUE) adds promised file, Imports magrittr", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE, {
      scoped_temporary_package()
      use_pipe(export = TRUE)
      expect_match(desc::desc_get("Imports", proj_get()), "magrittr")
      expect_proj_file("R", "utils-pipe.R")
    }
  )
})

test_that("use_pipe(export = FALSE) adds roxygen to package doc", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE, {
      scoped_temporary_package()
      use_package_doc()
      use_pipe(export = FALSE)
      expect_match(desc::desc_get("Imports", proj_get()), "magrittr")
      package_doc <- readLines(proj_path(package_doc_path()))
      expect_match(package_doc, "#' @importFrom magrittr %>%", all = FALSE)
    }
  )
})

test_that("use_pipe(export = FALSE) gives advice if no package doc", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE, {
      scoped_temporary_package()
      withr::local_options(list(usethis.quiet = FALSE))
      expect_output(
        use_pipe(export = FALSE),
        "Copy and paste this line"
      )
      expect_match(desc::desc_get("Imports", proj_get()), "magrittr")
    }
  )
})
