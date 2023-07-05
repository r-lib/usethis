test_that("Can add an author and then another", {
  withr::local_options(usethis.description = NULL)
  create_local_package()

  local_interactive(FALSE)
  use_author(
    "Jennifer", "Bryan",
    email = "jenny@posit.co",
    comment = c(ORCID = "0000-0002-6983-2759")
  )

  d <- proj_desc()
  ctb <- d$get_author(role = "ctb")
  expect_equal(ctb$given, "Jennifer")
  expect_equal(ctb$family, "Bryan")
  expect_equal(ctb$email, "jenny@posit.co")
  expect_equal(ctb$comment, c(ORCID = "0000-0002-6983-2759"))

  use_author(
    "Hadley", "Wickham",
    email = "hadley@posit.co",
    role = c("rev", "fnd")
  )

  d <- proj_desc()
  rev <- d$get_author(role = "rev")
  fnd <- d$get_author(role = "fnd")
  expect_equal(rev$given, "Hadley")
  expect_equal(rev$family, "Wickham")
  expect_equal(fnd$given, "Hadley")
  expect_equal(fnd$family, "Wickham")
})

test_that("Legacy author fields are challenged", {
  withr::local_options(usethis.description = NULL)
  create_local_package()

  d <- proj_desc()
  # I'm sort of deliberately leaving Authors@R there, just to make things
  # even less ideal. But one could do:
  # d$del("Authors@R")

  # used BH as of 2023-04-19 as my example of a package that uses
  # Author and Maintainer and does not use Authors@R
  d$set(Maintainer = "Dirk Eddelbuettel <edd@debian.org>")
  d$set(Author = "Dirk Eddelbuettel, John W. Emerson and Michael J. Kane")
  d$write()

  local_interactive(FALSE)
  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(challenge_legacy_author_fields(), error = TRUE)
})

test_that("Decline to tweak an existing author", {
  withr::local_options(
    usethis.description = list(
      "Authors@R" = utils::person(
        "Jennifer", "Bryan",
        email = "jenny@posit.co",
        role = c("aut", "cre"),
        comment = c(ORCID = "0000-0002-6983-2759")
      )
    )
  )
  create_local_package()

  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(
    use_author("Jennifer", "Bryan", role = "cph"),
    error = TRUE
  )
})

test_that("Placeholder author is challenged", {
  # apparently the format method for `person` used to handle ORCIDs differently
  skip_if(getRversion() < "4.0")

  withr::local_options(usethis.description = NULL)
  create_local_package()

  local_interactive(FALSE)
  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(use_author("Charlie", "Brown"))
})
