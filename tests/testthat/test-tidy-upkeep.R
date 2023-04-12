test_that("tidy upkeep bullets don't change accidentally", {
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
    tidy_upkeep_checklist(posit_pkg = TRUE, posit_person_ok = FALSE)
  ))
})

test_that("upkeep bullets don't change accidentally",{
  withr::local_options(
    usethis.descriptn = list(
      "Authors@R" = utils::person(
        "Jane", "Doe",
        email = "jane@foofymail.com",
        role = c("aut", "cre")
      ),
      License = "MIT + file LICENSE"
    )
  )
  create_local_package()
  use_git()
  repo <- git_repo()
  gert::git_add(".gitignore", repo = repo)
  gert::git_commit("a commit, so we are not on an unborn branch", repo = repo)

  expect_snapshot(writeLines(
    upkeep_checklist()
  ))
})
