context("use_ui")

test_that("use_ui() requires a package", {
  scoped_temporary_project()
  expect_usethis_error(use_ui(), "not an R package")
})

test_that("use_ui() Imports usethis", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE, {

      scoped_temporary_package()
      use_package_doc()
      use_ui()

      expect_match(desc::desc_get("Imports", proj_get()), "usethis")

      package_doc <- readLines(proj_path(package_doc_path()))
      expect_match(
        package_doc,
        "^#' @importFrom usethis ui_line ui_todo ui_done ui_todo ui_oops ui_info",
        all = FALSE
      )
      expect_match(package_doc, "^#' @importFrom usethis ui_code_block", all = FALSE)
      expect_match(package_doc, "^#' @importFrom usethis ui_stop ui_warn", all = FALSE)
      expect_match(package_doc, "^#' @importFrom usethis ui_yeah ui_nope", all = FALSE)
      expect_match(
        package_doc,
        "^#' @importFrom usethis ui_field ui_value ui_path ui_code", all = FALSE
      )

    }
  )
})
