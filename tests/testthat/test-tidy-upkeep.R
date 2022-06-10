test_that("upkeep bullets don't change accidentally", {
  expect_snapshot(writeLines(
    upkeep_checklist(rstudio_pkg = TRUE, rstudio_person_ok = FALSE)
  ))
})
