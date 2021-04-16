test_that("use_data() errors for a non-package project", {
  create_local_project()
  expect_usethis_error(use_data(letters), "not an R package")
})

test_that("use_data() stores new, non-internal data", {
  pkg <- create_local_package()
  letters2 <- letters
  month.abb2 <- month.abb
  expect_false(desc::desc_has_fields("LazyData"))
  use_data(letters2, month.abb2)
  expect_true(desc::desc_has_fields("LazyData"))
  rm(letters2, month.abb2)

  load(proj_path("data", "letters2.rda"))
  load(proj_path("data", "month.abb2.rda"))
  expect_identical(letters2, letters)
  expect_identical(month.abb2, month.abb)
})

test_that("use_data() honors `overwrite` for non-internal data", {
  pkg <- create_local_package()
  letters2 <- letters
  use_data(letters2)

  expect_usethis_error(use_data(letters2), ".*data/letters2.rda.* already exist")

  letters2 <- rev(letters)
  use_data(letters2, overwrite = TRUE)

  load(proj_path("data", "letters2.rda"))
  expect_identical(letters2, rev(letters))
})

test_that("use_data() stores new internal data", {
  pkg <- create_local_package()
  letters2 <- letters
  month.abb2 <- month.abb
  use_data(letters2, month.abb2, internal = TRUE)
  rm(letters2, month.abb2)

  load(proj_path("R", "sysdata.rda"))
  expect_identical(letters2, letters)
  expect_identical(month.abb2, month.abb)
})

test_that("use_data() honors `overwrite` for internal data", {
  pkg <- create_local_package()
  letters2 <- letters
  use_data(letters2, internal = TRUE)
  rm(letters2)

  expect_usethis_error(
    use_data(letters2, internal = TRUE),
    ".*R/sysdata.rda.* already exist"
  )

  letters2 <- rev(letters)
  use_data(letters2, internal = TRUE, overwrite = TRUE)

  load(proj_path("R", "sysdata.rda"))
  expect_identical(letters2, rev(letters))
})

test_that("use_data() writes version 2 by default", {
  create_local_package()

  x <- letters
  use_data(x, internal = TRUE, version = 2, compress = FALSE)
  expect_identical(
    rawToChar(readBin(proj_path("R", "sysdata.rda"), n = 4, what = "raw")),
    "RDX2"
  )
})

test_that("use_data_raw() does setup", {
  create_local_package()
  use_data_raw(open = FALSE)
  expect_proj_file(path("data-raw", "DATASET.R"))

  use_data_raw("daisy", open = FALSE)
  expect_proj_file(path("data-raw", "daisy.R"))

  expect_true(is_build_ignored("^data-raw$"))
})
