test_that("is.numeric returns TRUE if all elements of a vector are integers", {
  # Arrange
  x <- c(1L, 2L, 3L)

  # Act
  result <- is.numeric(x)

  # Assert
  expect_true(result)
})
