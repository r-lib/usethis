test_that("use_rstudio() creates .Rproj file, named after directory", {
  dir <- create_local_package(rstudio = FALSE)
  use_rstudio()
  rproj <- path_file(dir_ls(proj_get(), regexp = "[.]Rproj$"))
  expect_identical(path_ext_remove(rproj), path_file(dir))

  # Always uses POSIX line endings
  expect_equal(proj_line_ending(), "\n")
})

test_that("use_rstudio() can opt-out of reformatting", {
  create_local_project(rstudio = FALSE)
  use_rstudio(reformat = FALSE)
  out <- readLines(rproj_path())
  expect_true(is.na(match("AutoAppendNewline", out)))
  expect_true(is.na(match("StripTrailingWhitespace", out)))
  expect_true(is.na(match("LineEndingConversion", out)))
})

test_that("use_rstudio() omits package-related config for a project", {
  create_local_project(rstudio = FALSE)
  use_rstudio()
  out <- readLines(rproj_path())
  expect_true(is.na(match("BuildType: Package", out)))
})

test_that("an RStudio project is recognized", {
  create_local_package(rstudio = TRUE)
  expect_true(is_rstudio_project())
  expect_match(rproj_path(), "\\.Rproj$")
})

test_that("we error if there isn't exactly one Rproj files", {
  dir <- withr::local_tempdir()
  path <- dir_create(path(dir, "test"))

  expect_snapshot(rproj_path(path), error = TRUE)

  file_touch(path(path, "a.Rproj"))
  file_touch(path(path, "b.Rproj"))
  expect_snapshot(rproj_path(path), error = TRUE)
})

test_that("a non-RStudio project is not recognized", {
  create_local_package(rstudio = FALSE)
  expect_false(is_rstudio_project())
  expect_snapshot(rproj_path(), error = TRUE, transform = scrub_testpkg)
})


test_that("Rproj is parsed (actually, only colon-containing lines)", {
  tmp <- withr::local_tempfile()
  writeLines(c("a: a", "", "b: b", "I have no colon"), tmp)
  expect_identical(
    parse_rproj(tmp),
    list(a = "a", "", b = "b", "I have no colon")
  )
})

test_that("Existing field(s) in Rproj can be modified", {
  tmp <- withr::local_tempfile()
  writeLines(
    c(
      "Version: 1.0",
      "",
      "RestoreWorkspace: Default",
      "SaveWorkspace: Yes",
      "AlwaysSaveHistory: Default"
    ),
    tmp
  )
  before <- parse_rproj(tmp)
  delta <- list(RestoreWorkspace = "No", SaveWorkspace = "No")
  after <- modify_rproj(tmp, delta)
  expect_identical(before[c(1, 2, 5)], after[c(1, 2, 5)])
  expect_identical(after[3:4], delta)
})

test_that("we can roundtrip an Rproj file", {
  create_local_package(rstudio = TRUE)
  rproj_file <- rproj_path()
  before <- read_utf8(rproj_file)
  rproj <- modify_rproj(rproj_file, list())
  writeLines(serialize_rproj(rproj), rproj_file)
  after <- read_utf8(rproj_file)
  expect_identical(before, after)
})

test_that("use_blank_state('project') modifies Rproj", {
  create_local_package(rstudio = TRUE)
  use_blank_slate("project")
  rproj <- parse_rproj(rproj_path())
  expect_equal(rproj$RestoreWorkspace, "No")
  expect_equal(rproj$SaveWorkspace, "No")
})

test_that("use_blank_state() modifies user-level RStudio prefs", {
  path <- withr::local_tempdir()
  withr::local_envvar(c("XDG_CONFIG_HOME" = path))

  use_blank_slate()

  prefs <- rstudio_prefs_read()
  expect_equal(prefs[["save_workspace"]], "never")
  expect_false(prefs[["load_workspace"]])
})

test_that("use_rstudio_preferences", {
  path <- withr::local_tempdir()
  withr::local_envvar(c("XDG_CONFIG_HOME" = path))

  use_rstudio_preferences(x = 1, y = "a")

  prefs <- rstudio_prefs_read()
  expect_equal(prefs$x, 1)
  expect_equal(prefs$y, "a")
})
