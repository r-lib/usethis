scoped_temporary_package <- function(dir = tempfile(),
                                     env = parent.frame(),
                                     rstudio = FALSE) {
  scoped_temporary_thing(dir, env, rstudio, "package")
}

scoped_temporary_project <- function(dir = tempfile(),
                                     env = parent.frame(),
                                     rstudio = FALSE) {
  scoped_temporary_thing(dir, env, rstudio, "project")
}

scoped_temporary_thing <- function(dir = tempfile(),
                                   env = parent.frame(),
                                   rstudio = FALSE,
                                   thing = c("package", "project")) {
  thing <- match.arg(thing)
  old <- proj$cur
  # Can't schedule a deferred project reset if calling this from the R console,
  # which is useful when developing tests
  if (identical(env, globalenv())) {
    todo(
      "Switching to a temporary project! To restore current project:\n",
      "proj_set(\"", old, "\")"
    )
  } else {
    withr::defer(proj_set(old), envir = env)
  }

  switch(
    thing,
    package = capture_output(create_package(dir, rstudio = rstudio, open = FALSE)),
    project = capture_output(create_project(dir, rstudio = rstudio, open = FALSE))
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
