test_that("check_edition() validates inputs", {
  expect_snapshot(check_edition(20), error = TRUE)
  expect_snapshot(check_edition("x"), error = TRUE)
  expect_equal(check_edition(1.5), 1)

  if (packageVersion("testthat") >= "2.99") {
    expect_equal(check_edition(), 3)
  } else {
    expect_equal(check_edition(), 2)
  }
})
