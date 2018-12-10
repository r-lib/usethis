context("use_dependency")

test_that("we message for new type and are silent for same type", {
  scoped_temporary_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_output(
    use_dependency("crayon", "Imports"),
    "Adding 'crayon' to Imports field"
  )
  expect_silent(use_dependency("crayon", "Imports"))
})

test_that("we message for version change and are silent for same version", {
  scoped_temporary_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_output(
    use_dependency("crayon", "Imports"),
    "Adding 'crayon"
  )
  expect_output(
    use_dependency("crayon", "Imports", min_version = "1.0.0"),
    "Increasing 'crayon'"
  )
  expect_silent(use_dependency("crayon", "Imports", min_version = "1.0.0"))
  expect_output(
    use_dependency("crayon", "Imports", min_version = "2.0.0"),
    "Increasing 'crayon'"
  )
  expect_silent(use_dependency("crayon", "Imports", min_version = "1.0.0"))
})

## https://github.com/r-lib/usethis/issues/99
test_that("use_dependency() upgrades a dependency", {
  scoped_temporary_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_output(use_dependency("usethis", "Suggests"))
  expect_match(desc::desc_get("Suggests", proj_get()), "usethis")

  expect_output(use_dependency("usethis", "Imports"), "Moving 'usethis'")
  expect_match(desc::desc_get("Imports", proj_get()), "usethis")
  expect_false(grepl("usethis", desc::desc_get("Suggests", proj_get())))
})

## https://github.com/r-lib/usethis/issues/99
test_that("use_dependency() declines to downgrade a dependency", {
  scoped_temporary_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_output(use_dependency("usethis", "Imports"))
  expect_match(desc::desc_get("Imports", proj_get()), "usethis")

  expect_warning(use_dependency("usethis", "Suggests"), "no change")
  expect_match(desc::desc_get("Imports", proj_get()), "usethis")
  expect_false(grepl("usethis", desc::desc_get("Suggests", proj_get())))
})

test_that("can add LinkingTo dependency if other dependency already exists", {
  scoped_temporary_package()
  withr::local_options(list(usethis.quiet = FALSE))

  expect_output(use_dependency("Rcpp", "Imports"))
  expect_output(use_dependency("Rcpp", "LinkingTo"), "Adding 'Rcpp'")
})

test_that("can add any dependency if LinkingTo dependency already exists", {
  scoped_temporary_package()

  withr::local_options(list(usethis.quiet = FALSE))
  expect_output(use_dependency("Rcpp", "LinkingTo"))
  expect_output(use_dependency("Rcpp", "Import"), "Adding 'Rcpp'")
})
