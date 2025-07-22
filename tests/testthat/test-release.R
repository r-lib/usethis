# release bullets ---------------------------------------------------------

test_that("release bullets don't change accidentally", {
  withr::local_options(usethis.description = NULL)
  create_local_package()

  local_mocked_bindings(
    get_revdeps = function() "usethis"
  )

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

test_that("non-patch + lifecycle = advanced deprecation process", {
  withr::local_options(usethis.description = NULL)
  create_local_package()
  use_package("lifecycle")

  local_mocked_bindings(tidy_minimum_r_version = function() "3.6")

  has_deprecation <- function(x) any(grepl("deprecation processes", x))
  expect_true(has_deprecation(release_checklist("1.0.0", on_cran = TRUE)))
  expect_true(has_deprecation(release_checklist("1.1.0", on_cran = TRUE)))
  expect_false(has_deprecation(release_checklist("1.1.1", on_cran = TRUE)))
})

test_that("get extra news bullets if available", {
  env <- env(release_bullets = function() "Extra bullets")
  expect_equal(release_extra_bullets(env), "* [ ] Extra bullets")

  env <- env(release_questions = function() "Extra bullets")
  expect_equal(release_extra_bullets(env), "* [ ] Extra bullets")

  env <- env()
  expect_equal(release_extra_bullets(env), character())
})

test_that("construct correct revdep bullet", {
  create_local_package()
  env <- env(release_extra_revdeps = function() c("waldo", "testthat"))

  local_mocked_bindings(
    get_revdeps = function() "usethis"
  )

  expect_snapshot({
    release_revdepcheck(on_cran = FALSE)
    release_revdepcheck(on_cran = TRUE, is_posit_pkg = FALSE)
    release_revdepcheck(on_cran = TRUE, is_posit_pkg = TRUE)
    release_revdepcheck(on_cran = TRUE, is_posit_pkg = TRUE, env = env)
  })
})

test_that("RStudio-ness detection works", {
  withr::local_options(usethis.description = NULL)
  create_local_package()
  local_mocked_bindings(
    tidy_minimum_r_version = function() numeric_version("3.6"),
    get_revdeps = function() "usethis"
  )

  expect_false(is_posit_pkg())

  desc <- proj_desc()
  desc$add_author(given = "PoSiT, PbC", role = "fnd")
  desc$add_author(given = "someone", email = "someone@Rstudio.com")
  desc$add_urls("https://github.com/tidyverse/WHATEVER")
  desc$set_dep("R", "Depends", version = ">= 3.4")
  desc$write()

  expect_true(is_posit_pkg())
  expect_true(is_in_posit_org())
  expect_false(is_posit_person_canonical())
  expect_true(author_has_rstudio_email())

  expect_snapshot(
    writeLines(release_checklist("1.0.0", on_cran = TRUE)),
    transform = scrub_testpkg
  )
})

test_that("can find milestone numbers", {
  skip_if_offline("github.com")

  tr <- list(
    repo_owner = "r-lib",
    repo_name = "usethis",
    api_url = "https://api.github.com"
  )

  expect_equal(
    gh_milestone_number(tr, "2.1.6", state = "all"),
    8
  )
  expect_equal(
    gh_milestone_number(tr, "0.0.0", state = "all"),
    NA_integer_
  )
})

test_that("gh_milestone_number() returns NA when gh() errors", {
  local_mocked_bindings(
    gh_tr = function(tr) {
      function(endpoint, ...) {
        ui_abort("nope!")
      }
    }
  )
  tr <- list(
    repo_owner = "r-lib",
    repo_name = "usethis",
    api_url = "https://api.github.com"
  )
  expect_true(is.na(gh_milestone_number(tr, "1.1.1")))
})

# news --------------------------------------------------------------------

test_that("must have at least one heading", {
  expect_usethis_error(
    news_latest(""),
    regexp = "No top-level headings"
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
    glue(
      "
      This package was submitted to CRAN on YYYY-MM-DD.
      Once it is accepted, delete this file and tag the release (commit {HEAD})."
    )
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
    glue(
      "
      Version: 1.2.3
      Date: 2021-10-14 23:57:41 UTC
      SHA: {HEAD}"
    )
  )

  res <- get_release_data(tr = list(repo_spec = "OWNER/REPO"))
  expect_equal(res$Version, "1.2.3")
  expect_equal(res$SHA, HEAD)
  expect_equal(path_file(res$file), "CRAN-SUBMISSION")
})

test_that("cran_version() returns package version if package found", {
  local_mocked_bindings(available.packages = function(...) {
    # simulate minimal available.packages entry
    as.matrix(data.frame(Package = c(usethis = "usethis"), Version = "1.0.0"))
  })

  expect_null(cran_version("doesntexist"))
  expect_equal(cran_version("usethis"), package_version("1.0.0"))
})

test_that("cran_version() returns NULL if no available packages", {
  local_mocked_bindings(available.packages = function(...) NULL)
  expect_null(cran_version("doesntexist"))
})

test_that("default_cran_mirror() is respects set value but falls back to cloud", {
  withr::local_options(repos = c(CRAN = "https://example.com"))
  expect_equal(default_cran_mirror(), c(CRAN = "https://example.com"))

  withr::local_options(repos = c(CRAN = "@CRAN@"))
  expect_equal(default_cran_mirror(), c(CRAN = "https://cloud.r-project.org"))

  withr::local_options(repos = c())
  expect_equal(default_cran_mirror(), c(CRAN = "https://cloud.r-project.org"))
})

test_that("no revdep release bullets when there are no revdeps", {
  withr::local_options(usethis.description = NULL)
  create_local_package()

  local_mocked_bindings(
    get_revdeps = function() NULL
  )

  expect_snapshot(
    writeLines(release_checklist("1.0.0", on_cran = TRUE)),
    transform = scrub_testpkg
  )
})
