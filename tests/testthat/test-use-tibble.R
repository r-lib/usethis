context("use_tibble")

test_that("use_tibble() requires a package", {
  scoped_temporary_project()
  expect_error(use_tibble(), "not an R package")
})

test_that("use_tibble() adds promised file, Imports tibble", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE, {
      scoped_temporary_package()
      capture_output(use_tibble())
      expect_match(desc::desc_get("Imports", proj_get()), "tibble")
      expect_true(file.exists(proj_path("R", "utils-tibble.R")))
    }
  )
})
