test_that("valid_package_name() enforces valid package names", {
  # Contain only ASCII letters, numbers, and '.'
  # Have at least two characters
  # Start with a letter
  # Not end with '.'

  expect_true(valid_package_name("aa"))
  expect_true(valid_package_name("a7"))
  expect_true(valid_package_name("a.2"))

  expect_false(valid_package_name("a"))
  expect_false(valid_package_name("a-2"))
  expect_false(valid_package_name("2fa"))
  expect_false(valid_package_name(".fa"))
  expect_false(valid_package_name("aa\u00C0")) # \u00C0 is a-grave
  expect_false(valid_package_name("a3."))
})

test_that("valid_file_name() enforces valid file names", {
  # Contain only ASCII letters, numbers, '-', and '_'
  expect_true(valid_file_name("aa.R"))
  expect_true(valid_file_name("a7.R"))
  expect_true(valid_file_name("a-2.R"))
  expect_true(valid_file_name("a_2.R"))
  expect_false(valid_file_name("aa\u00C0.R")) # \u00C0 is a-grave
  expect_false(valid_file_name("a?3.R"))
})

# use_dependency ----------------------------------------------------------

test_that("we message for new type and are silent for same type", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_message(
    use_dependency("crayon", "Imports"),
    "Adding 'crayon' to Imports field"
  )
  expect_silent(use_dependency("crayon", "Imports"))
})

test_that("we message for version change and are silent for same version", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_message(
    use_dependency("crayon", "Imports"),
    "Adding 'crayon"
  )
  expect_message(
    use_dependency("crayon", "Imports", min_version = "1.0.0"),
    "Increasing 'crayon'"
  )
  expect_silent(use_dependency("crayon", "Imports", min_version = "1.0.0"))
  expect_message(
    use_dependency("crayon", "Imports", min_version = "2.0.0"),
    "Increasing 'crayon'"
  )
  expect_silent(use_dependency("crayon", "Imports", min_version = "1.0.0"))
})

## https://github.com/r-lib/usethis/issues/99
test_that("use_dependency() upgrades a dependency", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_message(use_dependency("usethis", "Suggests"))
  expect_match(desc::desc_get("Suggests", proj_get()), "usethis")

  expect_message(use_dependency("usethis", "Imports"), "Moving 'usethis'")
  expect_match(desc::desc_get("Imports", proj_get()), "usethis")
  expect_false(grepl("usethis", desc::desc_get("Suggests", proj_get())))
})

## https://github.com/r-lib/usethis/issues/99
test_that("use_dependency() declines to downgrade a dependency", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_message(use_dependency("usethis", "Imports"))
  expect_match(desc::desc_get("Imports", proj_get()), "usethis")

  expect_warning(use_dependency("usethis", "Suggests"), "no change")
  expect_match(desc::desc_get("Imports", proj_get()), "usethis")
  expect_false(grepl("usethis", desc::desc_get("Suggests", proj_get())))
})

test_that("can add LinkingTo dependency if other dependency already exists", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_message(use_dependency("Rcpp", "Imports"), "Adding 'Rcpp'")
  expect_message(use_dependency("Rcpp", "LinkingTo"), "Adding 'Rcpp'")
  expect_message(use_dependency("Rcpp", "LinkingTo"), "Adding 'Rcpp'")
  expect_message(use_dependency("Rcpp", "Import"), "Adding 'Rcpp'")
})
