test_that("use_tibble() requires a package", {
  create_local_project()
  expect_usethis_error(use_tibble(), "not an R package")
})

test_that("use_tibble() Imports tibble", {
  create_local_package(path_temp("mypackage"))
  withr::local_options(list(usethis.quiet = FALSE))
  expect_snapshot(use_tibble())
  expect_match(desc::desc_get("Imports", proj_get()), "tibble")
})
