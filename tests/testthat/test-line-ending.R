test_that("can detect path from RStudio project file", {
  create_local_package()
  use_rstudio("posix")
  expect_equal(proj_line_ending(), "\n")

  file_delete(proj_path(paste(paste0(project_name(), ".Rproj"))))
  use_rstudio("windows")
  expect_equal(proj_line_ending(), "\r\n")
})

test_that("can detect path from DESCRIPTION or .R file", {
  create_local_project()

  write_utf8(proj_path("DESCRIPTION"), c("x", "y", "z"), line_ending = "\r\n")
  expect_equal(proj_line_ending(), "\r\n")
  file_delete(proj_path("DESCRIPTION"))

  dir_create(proj_path("R"))
  write_utf8(proj_path("R/test.R"), c("x", "y", "z"), line_ending = "\r\n")
  expect_equal(proj_line_ending(), "\r\n")
})

test_that("falls back to platform specific encoding", {
  create_local_project()
  expect_equal(proj_line_ending(), platform_line_ending())
})

test_that("correctly detect line encoding", {
  path <- file_temp()

  con <- file(path, open = "wb")
  writeLines(c("a", "b", "c"), con, sep = "\n")
  close(con)
  expect_equal(detect_line_ending(path), "\n")

  con <- file(path, open = "wb")
  writeLines(c("a", "b", "c"), con, sep = "\r\n")
  close(con)
  expect_equal(detect_line_ending(path), "\r\n")
})
