expect_r_file <- function(...) {
  expect_true(file_exists(path_home_r(...)))
}

expect_fs_file <- function(...) {
  expect_true(file_exists(path_home(...)))
}


test_that("edit_file() creates new directory and another and a file within", {
  tmp <- file_temp()
  expect_false(dir_exists(tmp))
  capture.output(new_file <- edit_file(path(tmp, "new_dir", "new_file")))
  expect_true(dir_exists(tmp))
  expect_true(dir_exists(path(tmp, "new_dir")))
  expect_true(file_exists(path(tmp, "new_dir", "new_file")))
})

test_that("edit_file() creates new file in existing directory", {
  tmp <- file_temp()
  dir_create(tmp)
  capture.output(new_file <- edit_file(path(tmp, "new_file")))
  expect_true(file_exists(path(tmp, "new_file")))
})

test_that("edit_file() copes with path to existing file", {
  tmp <- file_temp()
  dir_create(tmp)
  existing <- file_create(path(tmp, "a_file"))
  capture.output(res <- edit_file(path(tmp, "a_file")))
  expect_identical(existing, res)
})

test_that("edit_template() can create a new template", {
  create_local_package()

  edit_template("new_template")
  expect_proj_file("inst/templates/new_template")
})

## testing edit_XXX("user") only on travis and appveyor, because I don't want to
## risk creating user-level files de novo for an actual user, which would
## obligate me to some nerve-wracking clean up

test_that("edit_r_XXX() and edit_git_XXX() have default scope", {
  skip_if_no_git_user()
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

  edit_r_makevars("user")
  expect_r_file(".R", "Makevars")
})

test_that("edit_r_buildignore() only works with packages", {
  create_local_project()

  expect_usethis_error(edit_r_buildignore(), "not an R package")

  use_description()
  edit_r_buildignore()
  expect_proj_file(".Rbuildignore")
})

test_that("can edit snippets", {
  path <- withr::local_tempdir()
  withr::local_envvar(c("XDG_CONFIG_HOME" = path))

  path <- edit_rstudio_snippets(type = "R")
  expect_true(file_exists(path))

  expect_error(
    edit_rstudio_snippets("not-existing-type"),
    regexp = "should be one of"
  )
})

test_that("edit_r_profile() respects R_PROFILE_USER", {
  path1 <- user_path_prep(file_temp())
  withr::local_envvar(list(R_PROFILE_USER = path1))

  path2 <- edit_r_profile("user")
  expect_equal(path1, path2)
})


test_that("edit_git_XXX('user') ensures the file exists", {
  skip_if_no_git_user()
  ## run these manually if you already have these files or are happy to
  ## have them or delete them
  skip_if_not_ci()

  edit_git_config("user")
  expect_fs_file(".gitconfig")

  edit_git_ignore("user")
  expect_fs_file(".gitignore")
  expect_match(
    git_cfg_get("core.excludesfile", where = "global"),
    "gitignore"
  )
})

test_that("edit_r_profile() ensures .Rprofile exists in project", {
  create_local_package()
  edit_r_profile("project")
  expect_proj_file(".Rprofile")

  create_local_project()
  edit_r_profile("project")
  expect_proj_file(".Rprofile")
})

test_that("edit_r_environ() ensures .Renviron exists in project", {
  create_local_package()
  edit_r_environ("project")
  expect_proj_file(".Renviron")

  create_local_project()
  edit_r_environ("project")
  expect_proj_file(".Renviron")
})

test_that("edit_r_makevars() ensures .R/Makevars exists in package", {
  create_local_package()
  edit_r_makevars("project")
  expect_proj_file(".R", "Makevars")
})

test_that("edit_git_config() ensures git ignore file exists in project", {
  create_local_package()
  edit_git_config("project")
  expect_proj_file(".git", "config")

  create_local_project()
  edit_git_config("project")
  expect_proj_file(".git", "config")
})

test_that("edit_git_ignore() ensures .gitignore exists in project", {
  create_local_package()
  edit_git_ignore("project")
  expect_proj_file(".gitignore")

  create_local_project()
  edit_git_ignore("project")
  expect_proj_file(".gitignore")
})
