test_that("use_addin() creates the first addins.dcf as promised", {
  create_local_package()
  use_addin("addin.test")

  addin_dcf <- read_utf8(proj_path("inst", "rstudio", "addins.dcf"))
  expected_file <- path_package("usethis", "templates", "addins.dcf")
  addin_dcf_expected <- read_utf8(expected_file)
  addin_dcf_expected[3] <- "Binding: addin.test"
  addin_dcf_expected[5] <- ""
  expect_equal(addin_dcf, addin_dcf_expected)
})
