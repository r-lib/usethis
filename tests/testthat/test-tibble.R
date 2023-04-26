test_that("use_tibble() requires a package", {
  create_local_project()
  expect_usethis_error(use_tibble(), "not an R package")
})

test_that("use_tibble() Imports tibble", {
  create_local_package(path_temp("mypackage"))
  withr::local_options(list(usethis.quiet = FALSE))
  ui_silence(use_package_doc())

  mock_check_installed()
  with_mock(
    roxygen_update_ns = function(...) NULL,
    check_functions_exist = function(...) TRUE,
    {
      expect_snapshot(use_tibble())
    }
  )

  expect_match(proj_desc()$get("Imports"), "tibble")
})
