test_that("git_default_branch() consults the default branch candidates, in order", {
  skip_on_cran()
  skip_if_no_git_user()
  local_interactive(FALSE)

  create_local_project()
  use_git()
  repo <- git_repo()

  gert::git_add(".gitignore", repo = repo)
  gert::git_commit("a commit, so we are not on an unborn branch", repo = repo)

  # singleton branch, with weird name
  git_default_branch_rename(from = git_branch(), to = "foofy")
  expect_equal(git_default_branch(), "foofy")

  # two weirdly named branches, but one matches init.defaultBranch (local) config
  gert::git_branch_create("blarg", checkout = TRUE, repo = repo)
  use_git_config("project", `init.defaultBranch` = "blarg")
  expect_equal(git_default_branch(), "blarg")

  # one of the Usual Suspects shows up
  gert::git_branch_create("master", checkout = TRUE, repo = repo)
  expect_equal(git_default_branch(), "master")

  # and another Usual Suspect shows up
  gert::git_branch_create("main", checkout = TRUE, repo = repo)
  expect_equal(git_default_branch(), "main")

  # finally, prefer something that matches what upstream says is default
  gert::git_branch_create(
    "default-branch-of-upstream",
    checkout = TRUE,
    repo = repo
  )
  local_git_default_branch_remote()
  expect_equal(git_default_branch(), "default-branch-of-upstream")
})

test_that("git_default_branch() errors if can't find obvious local default branch", {
  skip_on_cran()
  skip_if_no_git_user()
  local_interactive(FALSE)

  create_local_project()
  use_git()
  repo <- git_repo()

  gert::git_add(".gitignore", repo = repo)
  gert::git_commit("a commit, so we are not on an unborn branch", repo = repo)
  git_default_branch_rename(from = git_branch(), to = "foofy")

  gert::git_branch_create("blarg", checkout = TRUE, repo = repo)

  expect_error(git_default_branch(), class = "error_default_branch")
})

test_that("git_default_branch() errors for local vs remote mismatch", {
  skip_on_cran()
  skip_if_no_git_user()
  local_interactive(FALSE)

  create_local_project()
  use_git()
  repo <- git_repo()

  gert::git_add(".gitignore", repo = repo)
  gert::git_commit("a commit, so we are not on an unborn branch", repo = repo)
  git_default_branch_rename(from = git_branch(), to = "foofy")
  local_git_default_branch_remote()

  expect_error(git_default_branch(), class = "error_default_branch")

  gert::git_branch_create("blarg", checkout = TRUE, repo = repo)
  local_git_default_branch_remote()
  expect_error(git_default_branch(), class = "error_default_branch")
})

test_that("git_default_branch_rename() surfaces files that smell fishy", {
  skip_on_cran()
  skip_if_no_git_user()
  local_interactive(FALSE)

  # for snapshot purposes, I don't want a random project name
  create_local_project(path(path_temp(), "abcde"))
  use_git()
  repo <- git_repo()

  gert::git_add(".gitignore", repo = repo)
  gert::git_commit("a commit, so we are not on an unborn branch", repo = repo)

  # make sure we start with default branch = 'master'
  git_default_branch_rename(from = git_branch(), to = "master")
  expect_equal(git_default_branch(), "master")

  badge_lines <- c(
    "<!-- badges: start -->",
    "[![Codecov test coverage](https://codecov.io/gh/OWNER/REPO/branch/master/graph/badge.svg)](https://codecov.io/gh/OWNER/REPO?branch=master)",
    "<!-- badges: end -->"
  )
  cli::cat_line(badge_lines, file = proj_path("README.md"))

  gha_lines <- c(
    "on:",
    "  push:",
    "    branches:",
    "      - master"
  )
  create_directory(".github/workflows")
  cli::cat_line(gha_lines, file = path(".github", "workflows", "blah.yml"))

  create_directory("whatever/foo")
  cli::cat_line(
    "edit: https://github.com/OWNER/REPO/edit/master/%s",
    file = path("whatever", "foo", "_bookdown.yaml")
  )

  # The code to remind about updating codecov configuration,
  # `fishy_codecov_config()`, is not tested because it depends
  # on the location of a GitHub remote, which does not exist in this test.

  withr::local_options(usethis.quiet = FALSE)
  expect_snapshot(
    git_default_branch_rename()
  )
})
