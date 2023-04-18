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
  # mock test footer so doesn't change with date and usethis version
  local_mocked_bindings(checklist_footer = function(tidy) "test footer")

  expect_snapshot(writeLines(
    tidy_upkeep_checklist(posit_pkg = TRUE, posit_person_ok = FALSE)
  ))
})

test_that("upkeep bullets don't change accidentally",{
  skip_if_no_git_user()
  withr::local_options(usethis.description = NULL)
  create_local_package()
  local_mocked_bindings(
    git_default_branch = function() "main",
    checklist_footer = function(tidy) "test footer"
  )

  expect_snapshot(writeLines(
    upkeep_checklist()
  ))

  # Add some files to test conditional todos
  use_code_of_conduct("jane.doe@foofymail.com")
  use_citation()
  use_testthat()
  use_package("lifecycle")
  local_mocked_bindings(
    git_default_branch = function() "master"
  )

  expect_snapshot({
    local_edition(2L)
    writeLines(
      upkeep_checklist()
    )
  })
})

test_that("get extra upkeep bullets works", {
  env <- env(upkeep_bullets = function() c("extra", "upkeep bullets"))
  expect_equal(upkeep_extra_bullets(env),
               c("* [ ] extra", "* [ ] upkeep bullets", ""))

  env <- NULL
  expect_equal(upkeep_extra_bullets(env), "")
})
