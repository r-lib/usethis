test_that("use_tibble() requires a package", {
  create_local_project()
  expect_usethis_error(use_tibble(), "not an R package")
})

test_that("use_tibble() Imports tibble and imports tibble::tibble()", {
  create_local_package()

  withr::local_options(list(usethis.quiet = FALSE))
  local_roxygen_update_ns()
  local_check_installed()
  ui_silence(use_package_doc())
  local_check_fun_exists()

  expect_snapshot(
    use_tibble(),
    transform = scrub_testpkg
  )

  expect_match(proj_desc()$get("Imports"), "tibble")

  pkg_doc <- readLines(package_doc_path())
  expect_match(pkg_doc, "#' @importFrom tibble tibble", all = FALSE)
})
