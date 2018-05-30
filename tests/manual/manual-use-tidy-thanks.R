## this is annoyingly slow to have in the automated tests
## not to mention, a bit fragile
test_that("use_tidy_thanks() for a repo with contributors and releases", {
  skip_if_offline()
  skip_on_cran()
  capture.output(
    thanks <- use_tidy_thanks(
      owner = "r-lib", repo = "usethis",
      from = "2017-12-01", to = "v1.2.0"
    )
  )
  expect_type(thanks, "character")
  expect_true(all(c("jennybc", "hadley", "batpigandme") %in% thanks))
})
