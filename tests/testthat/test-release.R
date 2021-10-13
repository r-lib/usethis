
# release bullets ---------------------------------------------------------

test_that("release bullets don't change accidentally", {
  # Avoid finding any files in real usethis project
  # Take care to only change active project, but not working directory
  # Temporary project name must be stable
  tmpproj <- dir_create(path_temp("releasebullets"))
  withr::defer(dir_delete(tmpproj))
  file_create(path(tmpproj, ".here"))
  local_project(tmpproj, setwd = FALSE)

  # First release
  expect_snapshot(
    cat(release_checklist("0.1.0", on_cran = FALSE), sep = "\n")
  )

  # Patch release
  expect_snapshot(
    cat(release_checklist("0.0.1", on_cran = TRUE), sep = "\n")
  )

  # Major release
  expect_snapshot(
    cat(release_checklist("1.0.0", on_cran = TRUE), sep = "\n")
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

  write_utf8(
    proj_path("CRAN-RELEASE"),
    c("This package was submitted to CRAN on 2021-10-13.",
      "Once it is accepted, delete this file and tag the release (commit e10658f5).")
  )

  res <- get_release_data()
  expect_equal(res$Version, "0.0.0.9000")
  expect_equal(res$SHA, "e10658f5")
  expect_equal(path_file(res$file), "CRAN-RELEASE")
})

test_that("get_release_data() works for new-style CRAN-RELEASE", {
  skip_if_no_git_user()

  local_interactive(FALSE)
  create_local_package()
  use_git()
  gert::git_add(".gitignore")
  gert::git_commit("we need at least one commit")

  write_utf8(
    proj_path("CRAN-RELEASE"),
    c("Version: 2.4.2.9000",
      "Date: 2021-10-13 20:40:36 UTC",
      "SHA: fbe18b5a22be8ebbb61fa7436e826ba8d7f485a9"
    )
  )

  res <- get_release_data()
  expect_equal(res$Version, "2.4.2.9000")
  expect_equal(res$SHA, "fbe18b5a22be8ebbb61fa7436e826ba8d7f485a9")
  expect_equal(path_file(res$file), "CRAN-RELEASE")
})
