test_that("uses_github_actions() reports usage of GitHub Actions", {
  skip_if_no_git_user()
  skip_if_offline()

  create_local_package()
  expect_false(uses_github_actions())
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")
  with_mock(
    use_github_actions_badge = function(name, repo_spec) NULL,
    use_github_actions()
  )
  expect_true(uses_github_actions())
})

test_that("check_uses_github_actions() can throw error", {
  create_local_package()
  withr::local_options(list(crayon.enabled = FALSE))
  expect_error(
    check_uses_github_actions(),
    "Do you need to run `use_github_actions()`?",
    fixed = TRUE, class = "usethis_error"
  )
})

test_that("use_github_actions() configures GitHub Actions", {
  skip_if_no_git_user()
  skip_if_offline()

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")
  use_readme_md()

  use_github_actions()

  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/R-CMD-check.yaml")

  # YAML is correct
  yml <- yaml::yaml.load_file(proj_path(".github/workflows/R-CMD-check.yaml"))
  expect_identical(
    yml$name,
    "R-CMD-check"
  )
  expect_identical(
    names(yml$jobs),
    "R-CMD-check"
  )

  # Badge is correct
  readme_lines <- read_utf8(proj_path("README.md"))
  expect_true(any(grepl("R-CMD-check", readme_lines)))

  # .github has been Rbuildignored
  expect_true(is_build_ignored("^\\.github$"))
})

test_that("use_github_action_check_full() configures full GitHub Actions", {
  skip_if_no_git_user()
  skip_if_offline()

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")
  use_readme_md()

  use_github_action_check_full(repo_spec = "OWNER/REPO")
  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/R-CMD-check.yaml")

  # YAML is correct
  yml <- yaml::yaml.load_file(proj_path(".github/workflows/R-CMD-check.yaml"))
  expect_identical(
    yml$name,
    "R-CMD-check"
  )
  expect_identical(
    names(yml$jobs),
    "R-CMD-check"
  )

  # Should have a matrix of greater than 0
  expect_true(length(yml$jobs[[1]]$strategy$matrix) > 0)

  # Badge is correct
  readme_lines <- read_utf8(proj_path("README.md"))
  expect_true(any(grepl("R-CMD-check", readme_lines)))
})

test_that("use_github_action_check_full() configures the pr commands", {
  skip_if_no_git_user()
  skip_if_offline()

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")

  use_github_action_pr_commands()
  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/pr-commands.yaml")
})

test_that("use_tidy_github_actions() configures the full check and pr commands", {
  skip_if_no_git_user()
  skip_if_offline()

  create_local_package()
  use_git()
  gert::git_add(".gitignore", repo = git_repo())
  gert::git_commit("a commit, so we are not on an unborn branch", repo = git_repo())
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")
  use_readme_md()
  use_tidy_github_actions()

  expect_proj_file(".github/workflows/R-CMD-check.yaml")
  expect_proj_file(".github/workflows/pr-commands.yaml")
  expect_proj_file(".github/workflows/pkgdown.yaml")
})

test_that("use_github_action() allows for custom urls", {
  skip_if_no_git_user()
  skip_if_offline()

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")

  # Directly call to r-lib actions
  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(
    use_github_action(
      url = "https://raw.githubusercontent.com/r-lib/actions/master/examples/check-full.yaml",
      readme = "https://github.com/r-lib/actions/blob/master/examples/README.md"
    )
  )
  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/check-full.yaml")
})

test_that("use_github_action() appends yaml in name if missing", {
  skip_if_no_git_user()
  skip_if_offline()

  create_local_package()
  use_git()
  use_git_remote(name = "origin", url = "https://github.com/fake/fake")

  # Directly call to r-lib actions
  use_github_action("check-full")
  expect_proj_dir(".github")
  expect_proj_dir(".github/workflows")
  expect_proj_file(".github/workflows/check-full.yaml")
})
