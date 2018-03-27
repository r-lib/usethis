context("edit")

expect_user_file <- function(...) {
  expect_true(file.exists(scoped_path("user", ...)))
}

expect_user_git_file <- function(...) {
  expect_true(file.exists(scoped_git_path("user", ...)))
}

expect_project_file <- function(...) expect_true(file.exists(proj_path(...)))

## testing edit_XXX("user") only on travis and appveyor, because I don't want to
## risk creating user-level files de novo for an actual user, which would
## obligate me to some nerve-wracking clean up

test_that("edit_r_XXX('user') ensures the file exists", {
  ## run these manually if you already have these files or are happy to
  ## have them or delete them
  skip_if_not_ci()

  capture_output(edit_r_profile("user"))
  expect_user_file(".Rprofile")

  capture_output(edit_r_environ("user"))
  expect_user_file(".Renviron")

  capture_output(edit_r_makevars("user"))
  expect_user_file(".R", "Makevars")

  capture_output(edit_rstudio_snippets(type = "R"))
  expect_user_file(".R", "snippets", "r.snippets")
  capture_output(edit_rstudio_snippets(type = "HTML"))
  expect_user_file(".R", "snippets", "html.snippets")
})

test_that("edit_git_XXX('user') ensures the file exists", {
  ## run these manually if you already have these files or are happy to
  ## have them or delete them
  skip_if_not_ci()

  capture_output(edit_git_config("user"))
  expect_user_git_file(".gitconfig")

  capture_output(edit_git_ignore("user"))
  expect_user_git_file(".gitignore")
  cfg <- git2r::config()
  expect_match(cfg$global$core.excludesfile, "gitignore")
})

test_that("edit_r_profile() ensures .Rprofile exists in project", {
  scoped_temporary_package()
  capture_output(edit_r_profile("project"))
  expect_project_file(".Rprofile")

  scoped_temporary_project()
  capture_output(edit_r_profile("project"))
  expect_project_file(".Rprofile")
})

test_that("edit_r_environ() ensures .Renviron exists in project", {
  scoped_temporary_package()
  capture_output(edit_r_environ("project"))
  expect_project_file(".Renviron")

  scoped_temporary_project()
  capture_output(edit_r_environ("project"))
  expect_project_file(".Renviron")
})

test_that("edit_r_makevars() ensures .R/Makevars exists in package", {
  scoped_temporary_package()
  capture_output(edit_r_makevars("project"))
  expect_project_file(".R", "Makevars")
})

test_that("edit_git_config() ensures git ignore file exists in project", {
  scoped_temporary_package()
  capture_output(edit_git_config("project"))
  expect_project_file(".git", "config")

  scoped_temporary_project()
  capture_output(edit_git_config("project"))
  expect_project_file(".git", "config")
})

test_that("edit_git_ignore() ensures .gitignore exists in project", {
  scoped_temporary_package()
  capture_output(edit_git_ignore("project"))
  expect_project_file(".gitignore")

  scoped_temporary_project()
  capture_output(edit_git_ignore("project"))
  expect_project_file(".gitignore")
})
