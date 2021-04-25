if (require(testthat)) {
  library(usethis)

  test_check("usethis")
} else
  warning("'usethis' requires 'testthat' for tests")
