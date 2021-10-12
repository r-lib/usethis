test_that("upkeep bullets don't change accidentally", {
  expect_snapshot(cat(upkeep_checklist(), sep = "\n"))
})
