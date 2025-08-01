## If session temp directory appears to be, or be within, a project, there
## will be large scale, spurious test failures.
## The IDE sometimes leaves .Rproj files behind in session temp directory or
## one of its parents.
## Delete such files manually.
session_temp_proj <- proj_find(path_temp())
if (!is.null(session_temp_proj)) {
  Rproj_files <- fs::dir_ls(session_temp_proj, glob = "*.Rproj")
  ui_bullets(c(
    "x" = "Rproj {cli::qty(length(Rproj_files))} file{?s} found at or above session temp dir:",
    bulletize(usethis_map_cli(Rproj_files)),
    "!" = "Expect this to cause spurious test failures."
  ))
}

create_local_package <- function(
  dir = file_temp(pattern = "testpkg"),
  env = parent.frame(),
  rstudio = FALSE
) {
  create_local_thing(dir, env, rstudio, "package")
}

create_local_project <- function(
  # it is convenient if `dir` produces a project name that would be allowed for
  # a CRAN package, even for a generic project test fixture
  dir = file_temp(pattern = "testproj"),
  env = parent.frame(),
  rstudio = FALSE
) {
  create_local_thing(dir, env, rstudio, "project")
}

create_local_quarto_project <- function(
  dir = file_temp(pattern = "test-quarto-proj"),
  env = parent.frame(),
  rstudio = FALSE
) {
  create_local_thing(dir, env, rstudio, "quarto_project")
}

create_local_thing <- function(
  dir = file_temp(pattern = pattern),
  env = parent.frame(),
  rstudio = FALSE,
  thing = c("package", "project", "quarto_project")
) {
  thing <- match.arg(thing)
  if (fs::dir_exists(dir)) {
    ui_abort("Target {.arg dir} {.path {pth(dir)}} already exists.")
  }

  old_project <- proj_get_() # this could be `NULL`, i.e. no active project
  old_wd <- getwd() # not necessarily same as `old_project`

  withr::defer(
    {
      ui_bullets(c("v" = "Deleting temporary project: {.path {dir}}"))
      fs::dir_delete(dir)
    },
    envir = env
  )
  ui_silence(
    switch(
      thing,
      package = create_package(
        dir,
        # This is for the sake of interactive development of snapshot tests.
        # When the active usethis project is a package created with this
        # function, testthat learns its edition from *that* package, not from
        # usethis. So, by default, opt in to testthat 3e in these ephemeral test
        # packages.
        fields = list("Config/testthat/edition" = "3"),
        rstudio = rstudio,
        open = FALSE,
        check_name = FALSE
      ),
      project = create_project(dir, rstudio = rstudio, open = FALSE),
      quarto_project = create_quarto_project(
        dir,
        rstudio = rstudio,
        open = FALSE
      )
    )
  )

  withr::defer(proj_set(old_project, force = TRUE), envir = env)
  proj_set(dir)

  withr::defer(
    {
      ui_bullets(c(
        "v" = "Restoring original working directory: {.path {old_wd}}"
      ))
      setwd(old_wd)
    },
    envir = env
  )
  setwd(proj_get())

  invisible(proj_get())
}

scrub_testpkg <- function(message) {
  gsub("testpkg[a-zA-Z0-9]+", "{TESTPKG}", message, perl = TRUE)
}

scrub_testproj <- function(message) {
  gsub("testproj[a-zA-Z0-9]+", "{TESTPROJ}", message, perl = TRUE)
}

skip_if_not_ci <- function() {
  ci_providers <- c("GITHUB_ACTIONS", "TRAVIS", "APPVEYOR")
  ci <- any(toupper(Sys.getenv(ci_providers)) == "TRUE")
  if (ci) {
    return(invisible(TRUE))
  }
  skip("Not on GitHub Actions, Travis, or Appveyor")
}

skip_if_no_git_user <- function() {
  user_name <- git_cfg_get("user.name")
  user_email <- git_cfg_get("user.email")
  user_name_exists <- !is.null(user_name)
  user_email_exists <- !is.null(user_email)
  if (user_name_exists && user_email_exists) {
    return(invisible(TRUE))
  }
  skip("No Git user configured")
}

# CRAN's mac builder sets $HOME to a read-only ram disk, so tests can fail if
# you even tickle something that might try to lock its own config file during
# the operation (e.g. git) or if you simply test for writeability
skip_on_cran_macos <- function() {
  sysname <- tolower(Sys.info()[["sysname"]])
  on_cran <- !identical(Sys.getenv("NOT_CRAN"), "true")
  if (on_cran && sysname == "darwin") {
    skip("On CRAN and on macOS")
  }
  invisible(TRUE)
}

expect_usethis_error <- function(...) {
  expect_error(..., class = "usethis_error")
}

is_build_ignored <- function(pattern, ..., base_path = proj_get()) {
  lines <- read_utf8(path(base_path, ".Rbuildignore"))
  length(grep(pattern, x = lines, fixed = TRUE, ...)) > 0
}

test_file <- function(fname) testthat::test_path("ref", fname)

expect_proj_file <- function(...) expect_true(file_exists(proj_path(...)))
expect_proj_dir <- function(...) expect_true(dir_exists(proj_path(...)))
