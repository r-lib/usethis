scoped_temporary_package <- function(dir = tempfile(),
                                     env = parent.frame(),
                                     rstudio = FALSE) {
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

  capture_output(create_package(dir, rstudio = rstudio, open = FALSE))
  invisible(dir)
}
