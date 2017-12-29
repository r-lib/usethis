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

test_mode <- function() {
  before <- Sys.getenv("TESTTHAT")
  after <- if (before == "true") "false" else "true"
  Sys.setenv(TESTTHAT = after)
  cat("TESTTHAT:", before, "-->", after, "\n")
  invisible()
}
