test_that("use_data_table() requires a package", {
  create_local_project()
  expect_usethis_error(use_data_table(), "not an R package")
})

test_that("use_data_table() Imports data.table", {
  create_local_package()
  use_package_doc()
  with_mock(
    check_installed = function(pkg) TRUE,
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
