test_that("use_github_action() allows for custom urls", {
  skip_on_cran()
  skip_if_no_git_user()
  skip_if_offline()

  local_interactive(FALSE)

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/OWNER/REPO")

  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(
    use_github_action(
      url = "https://raw.githubusercontent.com/r-lib/actions/v1/examples/check-full.yaml",
      readme = "https://github.com/r-lib/actions/blob/v1/examples/README.md"
    )
  )
  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/check-full.yaml")
})

test_that("use_github_action() appends yaml in name if missing", {
  skip_on_cran()
  skip_if_no_git_user()
  skip_if_offline()
  local_interactive(FALSE)

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/OWNER/REPO")

  use_github_action("check-full")

  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/check-full.yaml")
})

test_that("uses_github_actions() reports usage of GitHub Actions", {
  skip_on_cran()
  skip_if_no_git_user()
  skip_if_offline()
  local_interactive(FALSE)

  create_local_package()
  expect_false(uses_github_actions())
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/OWNER/REPO")
  with_mock(
    use_github_actions_badge = function(name, repo_spec) NULL,
    use_github_actions()
  )
  expect_true(uses_github_actions())
})

test_that("check_uses_github_actions() can throw error", {
  create_local_package()
  withr::local_options(list(crayon.enabled = FALSE))
  expect_snapshot(
    check_uses_github_actions(),
    error = TRUE,
    transform = scrub_testpkg
  )
})

test_that("use_github_actions() configures the basic check action", {
  skip_on_cran()
  skip_if_no_git_user()
  skip_if_offline()
  local_interactive(FALSE)

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/OWNER/REPO")
  use_readme_md()

  use_github_actions()

  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/R-CMD-check.yaml")

  yml <- yaml::yaml.load_file(proj_path(".github/workflows/R-CMD-check.yaml"))
  expect_identical(yml$name, "R-CMD-check")
  expect_identical(names(yml$jobs), "R-CMD-check")

  readme_lines <- read_utf8(proj_path("README.md"))
  expect_true(any(grepl("R-CMD-check", readme_lines)))

  # .github has been Rbuildignored
  expect_true(is_build_ignored("^\\.github$"))
})

test_that("use_tidy_github_actions() configures the full check and pr commands", {
  skip_on_cran()
  skip_if_no_git_user()
  skip_if_offline()
  local_interactive(FALSE)

  create_local_package()
  use_git()
  gert::git_add(".gitignore", repo = git_repo())
  gert::git_commit("a commit, so we are not on an unborn branch", repo = git_repo())
  use_git_remote(name = "origin", url = "https://github.com/OWNER/REPO")
  use_readme_md()
  use_tidy_github_actions()

  expect_proj_file(".github/workflows/R-CMD-check.yaml")

  yml <- yaml::yaml.load_file(proj_path(".github/workflows/R-CMD-check.yaml"))
  expect_identical(yml$name, "R-CMD-check")
  expect_identical(names(yml$jobs), "R-CMD-check")

  size_build_matrix <-
    length(yml[["jobs"]][["R-CMD-check"]][["strategy"]][["matrix"]][["config"]])
  expect_true(size_build_matrix >= 6) # release, r-devel, 4 previous versions

  expect_proj_file(".github/workflows/pkgdown.yaml")
  expect_proj_file(".github/workflows/test-coverage.yaml")
  expect_proj_file(".github/workflows/pr-commands.yaml")

  readme_lines <- read_utf8(proj_path("README.md"))
  expect_true(any(grepl("R-CMD-check", readme_lines)))
  expect_true(any(grepl("test coverage", readme_lines)))
})
