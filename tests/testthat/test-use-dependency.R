context("use_dependency")

test_that("messages only when changing", {
  scoped_temporary_package()

  expect_output(
    use_dependency("crayon", "Imports"),
    "Adding 'crayon' to Imports field"
  )

  expect_output(
    use_dependency("crayon", "Imports"),
    NA
  )
})

test_that("or when changing the version", {
  scoped_temporary_package()

  expect_output(use_dependency("crayon", "Imports"))

  expect_output(
    use_dependency("crayon", "Imports", "> 1.0"),
    "Setting 'crayon'"
  )

  expect_output(
    use_dependency("crayon", "Imports", "> 1.0"),
    NA
  )

})
