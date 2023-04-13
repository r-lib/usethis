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
  skip_if_no_git_user()
  withr::local_options(usethis.description = NULL)
  create_local_package()

  # Need to add git so can detect presence of master branch
  use_git()
  repo <- git_repo()
  gert::git_add(".gitignore", repo = repo)
  gert::git_commit("a commit, so we are not on an unborn branch", repo = repo)

  expect_snapshot(writeLines(
    upkeep_checklist()
  ))

  # Add some files to test conditional todos
  use_code_of_conduct("jane.doe@foofymail.com")
  use_citation()
  use_testthat(3)
  desc::desc_set_dep("lifecycle")

  expect_snapshot(writeLines(
    upkeep_checklist()
  ))
})
