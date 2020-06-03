test_that("use_data_table() requires a package", {
  create_local_project()
  expect_usethis_error(use_data_table(), "not an R package")
})

test_that("use_data_table() Imports data.table", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE,
    `usethis:::is_installed` = function(pkg) TRUE,
    {
      create_local_package()
      use_data_table()
      expect_match(desc::desc_get("Imports", proj_get()), "data.table")
      datatable_doc <- read_utf8(proj_path("R", "utils-data-table.R"))
      expect_match(datatable_doc, "#' @import data.table", all = FALSE)
    }
  )
})
