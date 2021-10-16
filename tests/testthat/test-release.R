
# release bullets ---------------------------------------------------------

test_that("release bullets don't change accidentally", {
  create_local_package()

  # First release
  expect_snapshot(
    writeLines(release_checklist("0.1.0", on_cran = FALSE)),
    transform = scrub_testpkg
  )

  # Patch release
  expect_snapshot(
    writeLines(release_checklist("0.0.1", on_cran = TRUE)),
    transform = scrub_testpkg
  )

  # Major release
  expect_snapshot(
    writeLines(release_checklist("1.0.0", on_cran = TRUE)),
    transform = scrub_testpkg
  )
})

test_that("get extra news bullets if available", {
  env <- env(release_bullets = function() "Extra bullets")
  expect_equal(release_extra(env), "* [ ] Extra bullets")

  env <- env(release_questions = function() "Extra bullets")
  expect_equal(release_extra(env), "* [ ] Extra bullets")

  env <- env()
  expect_equal(release_extra(env), character())
})

test_that("RStudio-ness detection works", {
  create_local_package()

  expect_false(is_rstudio_funded())
  expect_false(is_in_rstudio_org())

  desc <- desc::desc(file = proj_get())
  desc$add_author(given = "RStudio", role = "fnd")
  desc$add_urls("https://github.com/tidyverse/WHATEVER")
  desc$write()

  expect_true(is_rstudio_funded())
  expect_true(is_in_rstudio_org())

  expect_snapshot(
    writeLines(release_checklist("1.0.0", on_cran = TRUE)),
    transform = scrub_testpkg
  )
})

# news --------------------------------------------------------------------

test_that("must have at least one heading", {
  expect_error(
    news_latest(""),
    regexp = "No top-level headings",
    class = "usethis_error"
  )
})

test_that("trims blank lines when extracting bullets", {
  lines <- c(
    "# Heading",
    "",
    "Contents",
    ""
  )
  expect_equal(news_latest(lines), "Contents\n")

  lines <- c(
    "# Heading",
    "",
    "Contents 1",
    "",
    "# Heading",
    "",
    "Contents 2"
  )
  expect_equal(news_latest(lines), "Contents 1\n")
})

test_that("returns empty string if no bullets", {
  lines <- c(
    "# Heading",
    "",
    "# Heading"
  )
  expect_equal(news_latest(lines), "")
})

# draft release ----------------------------------------------------------------
test_that("get_release_data() works if no file found", {
  skip_if_no_git_user()

  local_interactive(FALSE)
  create_local_package()
  use_git()
  gert::git_add(".gitignore")
  gert::git_commit("we need at least one commit")

  res <- get_release_data()
  expect_equal(res$Version, "0.0.0.9000")
  expect_match(res$SHA, "[[:xdigit:]]{40}")
})

test_that("get_release_data() works for old-style CRAN-RELEASE", {
  skip_if_no_git_user()

  local_interactive(FALSE)
  create_local_package()
  use_git()
  gert::git_add(".gitignore")
  gert::git_commit("we need at least one commit")
  HEAD <- gert::git_info(repo = git_repo())$commit

  write_utf8(
    proj_path("CRAN-RELEASE"),
    glue("
      This package was submitted to CRAN on YYYY-MM-DD.
      Once it is accepted, delete this file and tag the release (commit {HEAD}).")
  )

  res <- get_release_data(tr = list(repo_spec = "OWNER/REPO"))
  expect_equal(res$Version, "0.0.0.9000")
  expect_equal(res$SHA, HEAD)
  expect_equal(path_file(res$file), "CRAN-RELEASE")
})

test_that("get_release_data() works for new-style CRAN-RELEASE", {
  skip_if_no_git_user()

  local_interactive(FALSE)
  create_local_package()
  use_git()
  gert::git_add(".gitignore")
  gert::git_commit("we need at least one commit")
  HEAD <- gert::git_info(repo = git_repo())$commit

  write_utf8(
    proj_path("CRAN-SUBMISSION"),
    glue("
      Version: 1.2.3
      Date: 2021-10-14 23:57:41 UTC
      SHA: {HEAD}")
  )

  res <- get_release_data(tr = list(repo_spec = "OWNER/REPO"))
  expect_equal(res$Version, "1.2.3")
  expect_equal(res$SHA, HEAD)
  expect_equal(path_file(res$file), "CRAN-SUBMISSION")
})
