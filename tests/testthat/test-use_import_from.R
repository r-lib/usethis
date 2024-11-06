test_that("use_import_from() imports the related package & adds line to package doc", {
  create_local_package()
  use_package_doc()
  use_import_from("lifecycle", "deprecated")

  expect_equal(proj_desc()$get_field("Imports"), "lifecycle")
  expect_equal(roxygen_ns_show(), "#' @importFrom lifecycle deprecated")
})

test_that("use_import_from() adds one line for each function", {
  create_local_package()
  use_package_doc()
  use_import_from("lifecycle", c("deprecate_warn", "deprecate_stop"))

  expect_snapshot(roxygen_ns_show())
})

test_that("use_import_from() generates helpful errors", {
  create_local_package()
  use_package_doc()

  expect_snapshot(error = TRUE, {
    use_import_from(1)
    use_import_from(c("desc", "rlang"))

    use_import_from("desc", "pool_noodle")
  })
})
