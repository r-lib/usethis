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

test_that("use_lifecycle() adds RdMacros field", {
  create_local_package()
  with_mock(
    `usethis:::is_installed` = function(pkg) TRUE,
    use_lifecycle()
  )

  expect_true(desc::desc_has_fields("RdMacros"))
  expect_identical(desc::desc_get_field("RdMacros"), "lifecycle")
})

test_that("use_lifecycle() respects existing RdMacros field", {
  create_local_package()

  desc::desc_set(RdMacros = "foo, bar")
  with_mock(
    `usethis:::is_installed` = function(pkg) TRUE,
    use_lifecycle()
  )

  expect_true(desc::desc_has_fields("RdMacros"))
  expect_identical(desc::desc_get_field("RdMacros"), "foo, bar, lifecycle")
})
