context("use_tibble")

test_that("use_tibble() requires a package", {
  scoped_temporary_project()
  expect_usethis_error(use_tibble(), "not an R package")
})

test_that("use_tibble() Imports tibble", {
  with_mock(
    `usethis:::uses_roxygen` = function(base_path) TRUE, {
      scoped_temporary_package()
      withr::local_options(list(usethis.quiet = FALSE))
      expect_output(use_tibble(), "#' @importFrom tibble tibble")
      expect_match(desc::desc_get("Imports", proj_get()), "tibble")
    }
  )
})
