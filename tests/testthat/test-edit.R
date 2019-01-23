context("edit")

expect_r_file <- function(...) {
  expect_true(file_exists(path_home_r(...)))
}

expect_fs_file <- function(...) {
  expect_true(file_exists(path_home(...)))
}

## testing edit_XXX("user") only on travis and appveyor, because I don't want to
## risk creating user-level files de novo for an actual user, which would
## obligate me to some nerve-wracking clean up

test_that("edit_r_XXX() and edit_git_XXX() have default scope", {
  ## run these manually if you already have these files or are happy to
  ## have them or delete them
  skip_if_not_ci()

  ## on Windows, under R CMD check, some env vars are set to sentinel values
  ## https://github.com/wch/r-source/blob/78da6e06aa0017564ec057b768f98c5c79e4d958/src/library/tools/R/check.R#L257
  ## we need to explicitly ensure R_ENVIRON_USER="" here
  withr::local_envvar(list(R_ENVIRON_USER = ""))

  expect_error_free(edit_r_profile())
  expect_error_free(edit_r_buildignore())
  expect_error_free(edit_r_environ())
  expect_error_free(edit_r_makevars())
  expect_error_free(edit_git_config())
  expect_error_free(edit_git_ignore())
})

test_that("edit_r_XXX('user') ensures the file exists", {
  ## run these manually if you already have these files or are happy to
  ## have them or delete them
  skip_if_not_ci()

  ## on Windows, under R CMD check, some env vars are set to sentinel values
  ## https://github.com/wch/r-source/blob/78da6e06aa0017564ec057b768f98c5c79e4d958/src/library/tools/R/check.R#L257
  ## we need to explicitly ensure R_ENVIRON_USER="" here
  withr::local_envvar(list(R_ENVIRON_USER = ""))

  edit_r_environ("user")
  expect_r_file(".Renviron")

  edit_r_profile("user")
  expect_r_file(".Rprofile")

  edit_r_buildignore("user")
  expect_r_file(".Rbuildignore")

  edit_r_makevars("user")
  expect_r_file(".R", "Makevars")

  edit_rstudio_snippets(type = "R")
  expect_r_file(".R", "snippets", "r.snippets")
  edit_rstudio_snippets(type = "HTML")
  expect_r_file(".R", "snippets", "html.snippets")
})

test_that("edit_r_profile() respects R_PROFILE_USER", {
  path1 <- user_path_prep(file_temp())
  withr::local_envvar(list(R_PROFILE_USER = path1))

  path2 <- edit_r_profile("user")
  expect_equal(path1, as.character(path2))
})


test_that("edit_git_XXX('user') ensures the file exists", {
  ## run these manually if you already have these files or are happy to
  ## have them or delete them
  skip_if_not_ci()

  edit_git_config("user")
  expect_fs_file(".gitconfig")

  edit_git_ignore("user")
  expect_fs_file(".gitignore")
  cfg <- git2r::config()
  expect_match(cfg$global$core.excludesfile, "gitignore")
})

test_that("edit_r_profile() ensures .Rprofile exists in project", {
  scoped_temporary_package()
  edit_r_profile("project")
  expect_proj_file(".Rprofile")

  scoped_temporary_project()
  edit_r_profile("project")
  expect_proj_file(".Rprofile")
})

test_that("edit_r_environ() ensures .Renviron exists in project", {
  scoped_temporary_package()
  edit_r_environ("project")
  expect_proj_file(".Renviron")

  scoped_temporary_project()
  edit_r_environ("project")
  expect_proj_file(".Renviron")
})

test_that("edit_r_makevars() ensures .R/Makevars exists in package", {
  scoped_temporary_package()
  edit_r_makevars("project")
  expect_proj_file(".R", "Makevars")
})

test_that("edit_git_config() ensures git ignore file exists in project", {
  scoped_temporary_package()
  edit_git_config("project")
  expect_proj_file(".git", "config")

  scoped_temporary_project()
  edit_git_config("project")
  expect_proj_file(".git", "config")
})

test_that("edit_git_ignore() ensures .gitignore exists in project", {
  scoped_temporary_package()
  edit_git_ignore("project")
  expect_proj_file(".gitignore")

  scoped_temporary_project()
  edit_git_ignore("project")
  expect_proj_file(".gitignore")
})
