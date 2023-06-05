test_that("use_data_table() requires a package", {
  create_local_project()
  expect_usethis_error(use_data_table(), "not an R package")
})

test_that("use_data_table() Imports data.table", {
  create_local_package()
  use_package_doc()
  local_check_installed()
  local_roxygen_update_ns()
  local_check_fun_exists()

  use_data_table()

  expect_match(proj_desc()$get("Imports"), "data.table")
  expect_snapshot(roxygen_ns_show())
})

test_that("use_data_table() blocks use of Depends", {
  local_interactive(FALSE)

  create_local_package()
  use_package_doc()
  desc::desc_set("Depends", "data.table")
  local_check_installed()
  local_roxygen_update_ns()
  local_check_fun_exists()

  expect_warning(
    use_data_table(),
    "data.table should be in Imports or Suggests, not Depends"
  )

  expect_match(proj_desc()$get("Imports"), "data.table")
  expect_snapshot(roxygen_ns_show())
})
