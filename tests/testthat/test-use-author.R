context("use_author")

test_that("Author: field in description errors use_author()", {
  scoped_temporary_package()
  desc::desc_set(Author = "test")
  expect_error(use_author())
})

test_that("use_author() adds an author even with a blank Authors@R field in the DESCRIPTION.", {
  scoped_temporary_package()
  desc::desc_del("Author")
  desc::desc_set(`Authors@R` = "")
  use_author()
  expect_identical(desc::desc_get_authors(), person(given = "Jane", family = "Doe", role = "aut", email = "jane@example.com", comment = c(ORCID = "YOUR-ORCID-ID")))
})

test_that("Adding an author that is already in the DESCRIPTION errors use_author().", {
  scoped_temporary_package()
  desc::desc_del("Author")
  desc::desc_set(`Authors@R` = 'person(given = "Jane", family = "Doe", role = "aut", email = "jane@example.com", comment = c(ORCID = "YOUR-ORCID-ID"))')
  expect_error(use_author())
})

test_that("Adding a second author actually adds a second.", {
  scoped_temporary_package()
  desc::desc_del("Author")
  desc::desc_set(`Authors@R` = 'person(given = "Jane", family = "Doe", role = "aut", email = "jane@example.com", comment = c(ORCID = "YOUR-ORCID-ID"))')
  use_author(
    given = "Ali", family = "Val", role = "aut",
    email = "ali@example.com", comment = c(ORCID = "1111-ORCID-ID")
  )
  expect_length(desc::desc_get_authors(), 2)
})

# TODO write test to assess the use_author() function messages a user
# when the usethis default Authors@R field is specified. expect_message failed
# due to interactive nature of message. Not sure if it is possible without interactive sesssion.
