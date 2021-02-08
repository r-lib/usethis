test_that("use_stopwords() requires a package", {
  create_local_project()
  expect_usethis_error(use_stopwords(), "not an R package")
})

test_that("use_stopwords(export = TRUE) adds promised file, Imports magrittr", {
  create_local_package()
  use_stopwords(export = TRUE)
  expect_match(desc::desc_get("Imports", proj_get()), "stopwords")
  expect_proj_file("R", "utils-stopwords.R")
})

test_that("use_stopwords(export = FALSE) adds roxygen to package doc", {
  create_local_package()
  use_package_doc()
  use_stopwords(export = FALSE)
  expect_match(desc::desc_get("Imports", proj_get()), "stopwords")
  package_doc <- read_utf8(proj_path(package_doc_path()))
  expect_match(package_doc, "#' @importFrom stopwords stopwords", all = FALSE)
})

test_that("use_stopwords(export = FALSE) gives advice if no package doc", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE))
  expect_snapshot(use_stopwords(export = FALSE))
  expect_match(desc::desc_get("Imports", proj_get()), "stopwords")
})
