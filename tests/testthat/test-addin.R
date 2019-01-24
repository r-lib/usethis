context("use_addin")

test_that("use_addin() creates the first addins.dcf as promised", {
  scoped_temporary_package()
  use_addin("addin.test")

  addin_dcf <- readLines(proj_path("inst", "rstudio", "addins.dcf"))
  expected_file <- system.file("templates", "addins.dcf", package = "usethis")
  addin_dcf_expected <- readLines(expected_file)
  addin_dcf_expected[3] <- "Binding: addin.test"
  addin_dcf_expected[5] <- ""
  expect_equal(addin_dcf, addin_dcf_expected)
})

