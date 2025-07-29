test_that("check_edition() validates inputs", {
  local_mocked_bindings(testthat_version = function() numeric_version("3.2.0"))

  expect_snapshot(check_edition(20), error = TRUE)
  expect_snapshot(check_edition("x"), error = TRUE)
  expect_equal(check_edition(1.5), 1)
  expect_equal(check_edition(), 3)
})
