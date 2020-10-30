test_that("use_lifecycle() imports badges", {
  create_local_package()
  with_mock(
    `usethis:::is_installed` = function(pkg) TRUE,
    use_lifecycle()
  )
  expect_proj_file("man", "figures", "lifecycle-stable.svg")

  # Idempotent
  expect_error_free(use_lifecycle())
})
