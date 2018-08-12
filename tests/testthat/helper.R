## attempt to activate a project, which is nice during development
try(proj_set("."))

## putting `pattern` in the package or project name is part of our strategy for
## suspending the nested project check during testing
pattern <- "aaa"

scoped_temporary_package <- function(dir = file_temp(pattern = pattern),
                                     env = parent.frame(),
                                     rstudio = FALSE) {
  scoped_temporary_thing(dir, env, rstudio, "package")
}

scoped_temporary_project <- function(dir = file_temp(pattern = pattern),
                                     env = parent.frame(),
                                     rstudio = FALSE) {
  scoped_temporary_thing(dir, env, rstudio, "project")
}

scoped_temporary_thing <- function(dir = file_temp(pattern = pattern),
                                   env = parent.frame(),
                                   rstudio = FALSE,
                                   thing = c("package", "project")) {
  thing <- match.arg(thing)
  if (fs::dir_exists(dir)) {
    stop_glue("Target {code('dir')} {value(dir)} already exists.")
  }

  ## avoid proj_get() because it attempts to activate a project
  old_project <- proj$cur
  ## Can't schedule a deferred project reset if calling this from the R
  ## console, which is useful when developing tests
  if (identical(env, globalenv())) {
    done("Switching to a temporary project!")
    if (!is.null(old_project)) {
      todo(
        "Restore current project with: ",
        "{code('proj_set(\"', old_project, '\")')}"
      )
    }
  } else {
    withr::defer(proj_set(old_project, force = TRUE, quiet = TRUE), envir = env)
    withr::defer(fs::dir_delete(dir), envir = env)
  }

  withr::local_options(list(usethis.quiet = TRUE))
  switch(
    thing,
    package = create_package(dir, rstudio = rstudio, open = FALSE),
    project = create_project(dir, rstudio = rstudio, open = FALSE)
  )
  invisible(dir)
}

test_mode <- function() {
  before <- Sys.getenv("TESTTHAT")
  after <- if (before == "true") "false" else "true"
  Sys.setenv(TESTTHAT = after)
  cat("TESTTHAT:", before, "-->", after, "\n")
  invisible()
}

skip_if_not_ci <- function() {
  ci <- any(toupper(Sys.getenv(c("TRAVIS", "APPVEYOR"))) == "TRUE")
  if (ci) {
    return(invisible(TRUE))
  }
  skip("Not on Travis or Appveyor")
}

skip_if_no_git_config <- function() {
  cfg <- git2r::config()
  user_name <- cfg$local$`user.name` %||% cfg$global$`user.name`
  user_email <- cfg$local$`user.email` %||% cfg$global$`user.email`
  user_name_exists <- !is.null(user_name)
  user_email_exists <- !is.null(user_email)
  if (user_name_exists && user_email_exists) {
    return(invisible(TRUE))
  }
  skip("No Git user configured")
}

expect_error_free <- function(...) {
  expect_error(..., regexp = NA)
}

is_build_ignored <- function(pattern, ..., base_path = proj_get()) {
  lines <- readLines(path(base_path, ".Rbuildignore"), warn = FALSE)
  length(grep(pattern, x = lines, fixed = TRUE, ...)) > 0
}

test_file <- function(fname) testthat::test_path("ref", fname)

expect_proj_file <- function(...) expect_true(file_exists(proj_path(...)))
expect_proj_dir <- function(...) expect_true(dir_exists(proj_path(...)))

## use from testthat once > 2.0.0 is on CRAN
skip_if_offline <- function(host = "r-project.org") {
  skip_if_not_installed("curl")
  has_internet <- !is.null(curl::nslookup(host, error = FALSE))
  if (!has_internet) {
    skip("offline")
  }
}
