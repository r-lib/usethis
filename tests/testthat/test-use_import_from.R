test_that("use_import_from() imports the related package & adds line to package doc", {
  create_local_package()
  use_package_doc()
  use_import_from("tibble", "tibble")

  expect_equal(trimws(desc::desc_get("Imports", proj_get()))[[1]], "tibble")
  expect_equal(roxygen_ns_show(), "#' @importFrom tibble tibble")
})

test_that("use_import_from() adds one line for each function", {
  create_local_package()
  use_package_doc()
  use_import_from("tibble", c("tibble", "enframe", "deframe"))

  expect_snapshot(roxygen_ns_show())
})

test_that("use_import_from() generates helpful errors", {
  create_local_package()
  use_package_doc()

  expect_snapshot(error = TRUE, {
    use_import_from(1)
    use_import_from(c("tibble", "rlang"))

    use_import_from("tibble", "pool_noodle")
  })
})
