context("write helpers")

test_that("same_contents() detects if contents are / are not same", {
  tmp <- tempfile()
  x <- letters[1:3]
  writeLines(x, con = tmp, sep = "\n")
  expect_true(same_contents(tmp, x))
  expect_false(same_contents(tmp, letters[4:6]))
})
