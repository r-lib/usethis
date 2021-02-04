
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
  create_local_package()

  standard <- release_checklist("1.0.0", TRUE)

  attach(
    list(release_bullets = function() "Extra bullets"),
    name = "extra",
    warn.conflicts = FALSE
  )
  withr::defer(detach("extra"))

  new <- setdiff(release_checklist("1.0.0", TRUE), standard)
  expect_equal(new, "* [ ] Extra bullets")
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
