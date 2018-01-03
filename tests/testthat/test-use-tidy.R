context("tidyverse")

test_that("use_tidy_description() alphabetises dependencies", {
  pkg <- scoped_temporary_package()
  capture_output(use_package("usethis"))
  capture_output(use_package("desc"))
  capture_output(use_package("withr", "Suggests"))
  capture_output(use_package("gh", "Suggests"))
  capture_output(use_tidy_description())
  desc <- readLines(proj_path("DESCRIPTION"))
  expect_gt(grep("usethis", desc), grep("desc", desc))
  expect_gt(grep("withr", desc), grep("gh", desc))
})

test_that("use_tidy_versions() specifies a version for all dependencies", {
  pkg <- scoped_temporary_package()
  capture_output(use_package("usethis"))
  capture_output(use_package("desc"))
  capture_output(use_package("withr", "Suggests"))
  capture_output(use_package("gh", "Suggests"))
  capture_output(use_tidy_versions())
  desc <- readLines(proj_path("DESCRIPTION"))
  desc <- grep("usethis|desc|withr|gh", desc, value = TRUE)
  expect_true(all(grepl("\\(>= [0-9.]+\\)", desc)))
})

test_that("use_tidy_eval() inserts the template file and Imports rlang", {
  pkg <- scoped_temporary_package()
  ## fake the use of roxygen; this better in a test than use_roxygen_md()
  capture_output(
    use_description_field(name = "RoxygenNote", value = "6.0.1.9000")
  )
  capture_output(use_tidy_eval())
  expect_match(list.files(proj_path("R")), "utils-tidy-eval.R")
  expect_match(desc::desc_get("Imports", pkg), "rlang")
})
