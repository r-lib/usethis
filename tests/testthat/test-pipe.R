test_that("use_pipe() requires a package", {
  create_local_project()
  expect_usethis_error(use_pipe(), "not an R package")
})

test_that("use_pipe(export = TRUE) adds promised file, Imports magrittr", {
  create_local_package()
  use_pipe(export = TRUE)
  expect_match(desc::desc_get("Imports", proj_get()), "magrittr")
  expect_proj_file("R", "utils-pipe.R")
})

test_that("use_pipe(export = FALSE) adds roxygen to package doc", {
  create_local_package()
  use_package_doc()
  use_pipe(export = FALSE)
  expect_match(desc::desc_get("Imports", proj_get()), "magrittr")
  package_doc <- read_utf8(proj_path(package_doc_path()))
  expect_match(package_doc, "#' @importFrom magrittr %>%", all = FALSE)
})

