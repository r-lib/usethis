test_that("use_tibble() requires a package", {
  create_local_project()
  expect_usethis_error(use_tibble(), "not an R package")
})

test_that("use_tibble() Imports tibble", {
  create_local_package(path_temp("mypackage"))

  withr::local_options(list(usethis.quiet = FALSE))
  mock_roxygen_update_ns()
  mock_check_installed()
  ui_silence(use_package_doc())
  mock_check_functions_exist()

  expect_snapshot(use_tibble())

  expect_match(proj_desc()$get("Imports"), "tibble")
})
