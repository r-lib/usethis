test_that("use_data_table() requires a package", {
  create_local_project()
  expect_usethis_error(use_data_table(), "not an R package")
})

test_that("use_data_table() Imports data.table", {
  create_local_package()
  with_mock(
    is_installed = function(pkg) TRUE,
    use_data_table()
  )
  expect_match(desc::desc_get("Imports"), "data.table")
  datatable_doc <- read_utf8(proj_path("R", "utils-data-table.R"))
  expect_match(datatable_doc, "#' @import data.table", all = FALSE)
})
