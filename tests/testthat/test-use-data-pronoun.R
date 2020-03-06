test_that("use_data_pronoun() requires a package", {
  scoped_temporary_project()
  expect_usethis_error(use_data_pronoun(), "not an R package")
})

test_that("use_data_pronoun() adds roxygen to package doc", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE, {
      scoped_temporary_package()
      use_package_doc()
      use_data_pronoun()
      expect_match(desc::desc_get("Imports", proj_get()), "rlang")
      package_doc <- readLines(proj_path(package_doc_path()))
      expect_match(package_doc, "#' @importFrom rlang .data", all = FALSE)
    }
  )
})

test_that("use_data_pronoun() gives advice if no package doc", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE, {
      scoped_temporary_package()
      withr::local_options(list(usethis.quiet = FALSE))
      expect_message(
        use_data_pronoun(),
        "Copy and paste this line"
      )
      expect_match(desc::desc_get("Imports", proj_get()), "rlang")
    }
  )
})
