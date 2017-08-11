context("use_dependency")

test_that("messages only when changing", {
  tmp <- tempfile()
  create_package(tmp, rstudio = FALSE)

  expect_message(
    use_dependency("MASS", "Imports", base_path = tmp),
    "Adding 'MASS' to Imports field"
  )

  expect_message(
    use_dependency("MASS", "Imports", base_path = tmp),
    NA
  )
})

test_that("or when changing the version", {
  tmp <- tempfile()
  create_package(tmp, rstudio = FALSE)

  use_dependency("MASS", "Imports", base_path = tmp)

  expect_message(
    use_dependency("MASS", "Imports", "> 1.0", base_path = tmp),
    "Setting 'MASS'"
  )

  expect_message(
    use_dependency("MASS", "Imports", "> 1.0", base_path = tmp),
    NA
  )

})
