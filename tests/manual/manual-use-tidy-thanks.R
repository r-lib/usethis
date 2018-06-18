## this is annoyingly slow to have in the automated tests
## not to mention, a bit fragile

library(testthat)

## test use_tidy_thanks() on a repo with contributors and releases
thanks <- use_tidy_thanks(
  "r-lib/usethis",
  from = "2017-12-01", to = "v1.2.0"
)
expect_type(thanks, "character")
expect_true(all(c("jennybc", "hadley", "batpigandme") %in% thanks))
