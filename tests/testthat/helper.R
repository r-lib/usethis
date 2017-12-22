scoped_temporary_package <- function(dir = tempfile(), env = parent.frame()) {
  old <- proj$cur
  withr::defer(proj_set(old), envir = env)

  utils::capture.output(create_package(dir, rstudio = FALSE, open = FALSE))
  invisible(dir)
}
