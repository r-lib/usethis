test_that("use_data_table() requires a package", {
  create_local_project()
  expect_usethis_error(use_data_table(), "not an R package")
})

test_that("use_data_table() Imports data.table", {
  create_local_package()
  use_package_doc()
  mock_check_installed()
  with_mock(
    roxygen_update_ns = function(...) NULL,
    check_functions_exist = function(...) TRUE,
    {
      use_data_table()
    }
  )

  expect_match(proj_desc()$get("Imports"), "data.table")
  expect_snapshot(roxygen_ns_show())
})

test_that("use_data_table() blocks use of Depends", {
  create_local_package()
  use_package_doc()
  desc::desc_set("Depends", "data.table")
  mock_check_installed()
  with_mock(
    roxygen_update_ns = function(...) NULL,
    check_functions_exist = function(...) TRUE,
    {
      expect_warning(
        use_data_table(),
        "data.table should be in Imports or Suggests, not Depends"
      )
    }
  )

  expect_match(proj_desc()$get("Imports"), "data.table")
  expect_snapshot(roxygen_ns_show())
})
