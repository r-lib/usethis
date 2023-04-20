test_that("upkeep bullets don't change accidentally", {
  withr::local_options(
    usethis.description = list(
      "Authors@R" = utils::person(
        "Jane", "Doe",
        email = "jane@rstudio.com",
        role = c("aut", "cre")
      ),
      License = "MIT + file LICENSE"
    )
  )
  create_local_package()

  expect_snapshot(writeLines(
    upkeep_checklist(posit_pkg = TRUE, posit_person_ok = FALSE)
  ))
})
