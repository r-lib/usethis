test_that("tidy upkeep bullets don't change accidentally", {
  create_local_package()
  use_mit_license()
  expect_equal(last_upkeep_year(), 2000L)
  record_upkeep_date(as.Date("2022-04-04"))
  expect_equal(last_upkeep_year(), 2022L)

  local_mocked_bindings(
    Sys.Date = function() as.Date("2023-01-01"),
    usethis_version = function() "1.1.0",
    author_has_rstudio_email = function() TRUE,
    is_posit_pkg = function() TRUE,
    is_posit_person_canonical = function() FALSE
  )

  expect_snapshot(writeLines(tidy_upkeep_checklist()))
})

test_that("upkeep bullets don't change accidentally",{
  skip_if_no_git_user()

  create_local_package()

  local_mocked_bindings(
    Sys.Date = function() as.Date("2023-01-01"),
    usethis_version = function() "1.1.0",
    git_default_branch = function() "main"
  )

  expect_snapshot(writeLines(upkeep_checklist()))

  # Test some conditional TODOs
  use_code_of_conduct("jane.doe@foofymail.com")
  writeLines("# test environment\n", "cran-comments.md")
  local_mocked_bindings(git_default_branch = function() "master")

  # Look like a package that hasn't switched to testthat 3e yet
  use_testthat()
  desc::desc_del("Config/testthat/edition")
  desc::desc_del("Suggests")
  use_package("testthat", "Suggests")

  # previously (withr 2.5.0) we could put local_edition(2L) inside {..} inside
  # the expect_snapshot() call
  # that is no longer true with withr 3.0.0, but this hacktastic approach works
  local({
    local_edition(2L)
    checklist <<- upkeep_checklist()
  })

  expect_snapshot(writeLines(checklist))
})

test_that("get extra upkeep bullets works", {
  e <- new.env(parent = empty_env())
  expect_equal(upkeep_extra_bullets(e), "")

  e$upkeep_bullets <- function() c("extra", "upkeep bullets")
  expect_equal(
    upkeep_extra_bullets(e),
    c("* [ ] extra", "* [ ] upkeep bullets", "")
  )
})
