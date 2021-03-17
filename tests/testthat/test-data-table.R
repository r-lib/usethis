test_that("use_data_table() requires a package", {
  create_local_project()
  expect_usethis_error(use_data_table(), "not an R package")
})

test_that("use_data_table() Imports data.table", {
  create_local_package()
  use_package_doc()
  with_mock(
    check_installed = function(pkg) TRUE,
    check_fun_exists = function(...) TRUE,
    use_data_table()
  )
  expect_match(desc::desc_get("Imports"), "data.table")
  package_doc <- read_utf8(proj_path(package_doc_path()))

  purrr::walk(
    c("data.table", ":=", ".SD", ".BY", ".N", ".I", ".GRP", ".NGRP", ".EACHI"),
    ~ expect_match(
      package_doc,
      glue("#' @importFrom data.table {.x}"),
      all = FALSE
    )
  )
})

test_that("use_data_table() blocks use of Depends", {
  create_local_package()
  use_package_doc()
  desc::desc_set_dep("data.table", "Depends")
  with_mock(
    check_installed = function(pkg) TRUE,
    check_fun_exists = function(...) TRUE,
    expect_warning(
      use_data_table(),
      "data.table should be in Imports or Suggests, not Depends"
    )
  )
  expect_match(desc::desc_get("Imports"), "data.table")
  package_doc <- read_utf8(proj_path(package_doc_path()))

  purrr::walk(
    c("data.table", ":=", ".SD", ".BY", ".N", ".I", ".GRP", ".NGRP", ".EACHI"),
    ~ expect_match(
      package_doc,
      glue("#' @importFrom data.table {.x}"),
      all = FALSE
    )
  )
})
