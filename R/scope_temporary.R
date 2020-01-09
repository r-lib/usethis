# These functions are helpful for testing usethis functions
# and are therefore not intended for the enduser
# but may help developers of packages based on usehis

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
    ui_stop("Target {ui_code('dir')} {ui_path(dir)} already exists.")
  }

  old_project <- proj_get_()
  ## Can't schedule a deferred project reset if calling this from the R
  ## console, which is useful when developing tests
  if (identical(env, globalenv())) {
    ui_done("Switching to a temporary project!")
    if (!is.null(old_project)) {
      command <- paste0('proj_set(\"', old_project, '\")')
      ui_todo(
        "Restore current project with: {ui_code(command)}"
      )
    }
  } else {
    withr::defer({
      withr::with_options(
        list(usethis.quiet = TRUE),
        proj_set(old_project, force = TRUE)
      )
      setwd(old_project)
      fs::dir_delete(dir)
    }, envir = env)
  }

  withr::local_options(list(usethis.quiet = TRUE))
  switch(
    thing,
    package = create_package(dir, rstudio = rstudio, open = FALSE,
                             check_name = FALSE),
    project = create_project(dir, rstudio = rstudio, open = FALSE)
  )
  proj_set(dir)
  setwd(dir)
  invisible(dir)
}
