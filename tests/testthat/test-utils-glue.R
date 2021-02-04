test_that("glue_chr() returns plain character, evals in correct env", {
  x <- letters[1:2]
  y <- LETTERS[25:26]
  f <- toupper
  expect_identical(glue_chr("{f(x)}-{y}"), c("A-Y", "B-Z"))
})

test_that("glue_data_chr() returns plain character, evals in correct env", {
  z <- list(x = letters[1:2], y = LETTERS[25:26])
  f <- tolower
  x <- 1
  y <- 2
  expect_identical(glue_data_chr(z, "{x}-{f(y)}"), c("a-y", "b-z"))
})
