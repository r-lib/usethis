test_that("use_import_from() requires a package", {
  create_local_project()
  expect_usethis_error(use_import_from(), "not an R package")
})

test_that("use_import_from() imports the related package", {
  create_local_package()
  use_package_doc()
  use_import_from("tibble", "tibble")
  expect_match(desc::desc_get("Imports", proj_get()), "tibble")
})

test_that("use_import_from() adds @importFrom to package doc", {
  create_local_package()
  use_package_doc()
  use_import_from("tibble", "tibble")
  package_doc <- read_utf8(proj_path(package_doc_path()))
  expect_match(package_doc, "#' @importFrom tibble tibble", all = FALSE)
})
