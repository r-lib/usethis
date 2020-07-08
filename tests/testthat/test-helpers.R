
test_that("use_description_field() can address an existing field", {
  pkg <- create_local_package()
  orig <- tools::md5sum(proj_path("DESCRIPTION"))

  ## specify existing value of existing field --> should be no op
  use_description_field(
    name = "Version",
    value = desc::desc_get("Version", pkg)[[1]],
    base_path = pkg
  )
  expect_identical(orig, tools::md5sum(proj_path("DESCRIPTION")))

  expect_usethis_error(
    use_description_field(
      name = "Version",
      value = "1.1.1",
      base_path = pkg
    ),
    "has a different value"
  )

  ## overwrite existing field
  use_description_field(
    name = "Version",
    value = "1.1.1",
    base_path = pkg,
    overwrite = TRUE
  )
  expect_identical(c(Version = "1.1.1"), desc::desc_get("Version", pkg))
})

test_that("use_description_field() can add new field", {
  pkg <- create_local_package()
  use_description_field(name = "foo", value = "bar", base_path = pkg)
  expect_identical(c(foo = "bar"), desc::desc_get("foo", pkg))
})

test_that("use_description_field() ignores whitespace", {
  pkg <- create_local_package()
  use_description_field(name = "foo", value = "\n bar")
  use_description_field(name = "foo", value = "bar")
  expect_identical(c(foo = "\n bar"), desc::desc_get("foo", pkg))
})

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

# use_system_requirement ------------------------------------------------

test_that("we message for new requirements and are silent for existing requirements", {
  create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_message(
    use_system_requirement("C++11"),
    "Adding 'C++11' to SystemRequirements field in DESCRIPTION",
    fixed = TRUE
  )

  expect_silent(use_system_requirement("C++11"))
})

test_that("we can add multiple requirements with repeated calls", {
  pkg <- create_local_package()
  withr::local_options(list(usethis.quiet = FALSE, crayon.enabled = FALSE))

  expect_message(
    use_system_requirement("C++11"),
    "Adding 'C++11' to SystemRequirements field in DESCRIPTION",
    fixed = TRUE
  )

  expect_message(
    use_system_requirement("libxml2"),
    "Adding 'libxml2' to SystemRequirements field in DESCRIPTION",
    fixed = TRUE
  )

  expect_equal(
    unname(desc::desc_get("SystemRequirements", pkg)),
    "C++11, libxml2"
  )
})
