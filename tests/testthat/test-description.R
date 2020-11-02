
# use_description_defaults() ----------------------------------------------

test_that("user's fields > usethis defaults", {
  d <- use_description_defaults("pkg", fields = list(Title = "TEST1", URL = "TEST1"))
  expect_equal(d$Title, "TEST1")
  expect_equal(d$URL, "TEST1")
  expect_equal(d$Version, "0.0.0.9000")
})

test_that("usethis options > usethis defaults", {
  withr::local_options(list(
    usethis.description = list(License = "TEST")
  ))

  d <- use_description_defaults()
  expect_equal(d$License, "TEST")
  expect_equal(d$Version, "0.0.0.9000")
})

test_that("usethis options > usethis defaults, even for Authors@R", {
  withr::local_options(list(
    usethis.description = list(
      "Authors@R" = utils::person("Jane", "Doe")
    )
  ))
  d <- use_description_defaults()
  expect_equal(
    d$`Authors@R`,
    "person(given = \"Jane\",\n       family = \"Doe\")"
  )
  expect_match(d$`Authors@R`, '^person[(]given = "Jane"')
  expect_match(d$`Authors@R`, '"Doe"[)]$')
})

test_that("user's fields > options > defaults", {
  withr::local_options(list(
    usethis.description = list(License = "TEST1", Title = "TEST1")
  ))

  d <- use_description_defaults("pkg", fields = list(Title = "TEST2"))
  expect_equal(d$Title, "TEST2")
  expect_equal(d$License, "TEST1")
  expect_equal(d$Version, "0.0.0.9000")
})

test_that("automatically converts person object to text", {
  d <- use_description_defaults(
    "pkg",
    fields = list(`Authors@R` = person("H", "W"))
  )
  expect_match(d$`Authors@R`, '^person[(]given = "H"')
  expect_match(d$`Authors@R`, '"W"[)]$')
})

test_that("can set package", {
  d <- use_description_defaults(package = "TEST")
  expect_equal(d$Package, "TEST")
})

test_that("`roxygen = FALSE` is honoured", {
  d <- use_description_defaults(roxygen = FALSE)
  expect_null(d[["Roxygen"]])
  expect_null(d[["RoxygenNote"]])
})

# use_description ---------------------------------------------------------

test_that("creation succeeds even if options are broken", {
  withr::local_options(list(usethis.description = list(
    `Authors@R` = "person("
  )))
  create_local_project()

  expect_error(use_description(), NA)
})

test_that("default description is tidy", {
  withr::local_options(list(usethis.description = NULL, devtools.desc = NULL))
  create_local_package()

  before <- readLines(proj_path("DESCRIPTION"))
  use_tidy_description()
  after <- readLines(proj_path("DESCRIPTION"))
  expect_equal(before, after)
})

test_that("valid CRAN names checked", {
  withr::local_options(list(usethis.description = NULL, devtools.desc = NULL))
  create_local_package(dir = file_temp(pattern = "invalid_pkg_name"))

  expect_error(use_description(check_name = FALSE), NA)
  expect_error(
    use_description(check_name = TRUE),
    "is not a valid package name",
    class = "usethis_error"
  )
})
