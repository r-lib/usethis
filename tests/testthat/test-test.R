test_that("check_edition() validates inputs", {
  expect_error(check_edition(20), "not available")
  expect_error(check_edition("x"), "single number")
  expect_equal(check_edition(1.5), 1)

  if (packageVersion("testthat") >= "2.99") {
    expect_equal(check_edition(), 3)
  } else {
    expect_equal(check_edition(), 2)
  }
})
