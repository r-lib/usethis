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
  gert::git_branch_create("default-branch-of-upstream", checkout = TRUE, repo = repo)
  with_mock(
    git_default_branch_remote = function(remote) {
      list(
        name = remote,
        is_configured = TRUE,
        url = NA_character_,
        repo_spec = NA_character_,
        default_branch = as.character(glue("default-branch-of-{remote}"))
      )
    },
    expect_equal(git_default_branch(), "default-branch-of-upstream")
  )
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

  with_mock(
    git_default_branch_remote = function(remote) {
      list(
        name = remote,
        is_configured = TRUE,
        url = NA_character_,
        repo_spec = NA_character_,
        default_branch = as.character(glue("default-branch-of-{remote}"))
      )
    },
    expect_error(git_default_branch(), class = "error_default_branch")
  )

   gert::git_branch_create("blarg", checkout = TRUE, repo = repo)
   with_mock(
     git_default_branch_remote = function(remote) {
       list(
         name = remote,
         is_configured = TRUE,
         url = NA_character_,
         repo_spec = NA_character_,
         default_branch = as.character(glue("default-branch-of-{remote}"))
       )
     },
     expect_error(git_default_branch(), class = "error_default_branch")
   )
})
