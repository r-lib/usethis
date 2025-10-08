test_that("use_news_md() sets (development version)/'Initial submission' in new pkg", {
  create_local_package()
  local_cran_version(NULL)

  use_news_md()

  expect_snapshot(
    writeLines(read_utf8(proj_path("NEWS.md"))),
    transform = scrub_testpkg
  )
})

test_that("use_news_md() sets bullet to 'Added a NEWS.md file...' when on CRAN", {
  create_local_package()

  # on CRAN, local dev version
  proj_desc_field_update(key = "Version", value = "0.1.0.9000")
  local_cran_version("0.1.0")

  use_news_md()

  expect_snapshot(
    writeLines(read_utf8(proj_path("NEWS.md"))),
    transform = scrub_testpkg
  )
})

test_that("use_news_md() sets version number when 'production version'", {
  create_local_package()

  proj_desc_field_update(key = "Version", value = "0.2.0")
  local_cran_version(NULL)

  use_news_md()

  expect_snapshot(
    writeLines(read_utf8(proj_path("NEWS.md"))),
    transform = scrub_testpkg
  )
})

test_that("use_news_heading() tolerates blank lines at start", {
  create_local_package()

  header <- sprintf("# %s (development version)", project_name())
  writeLines(c("", header, "", "* Fixed the bugs."), con = "NEWS.md")

  use_news_heading(version = "1.0.0")
  contents <- read_utf8("NEWS.md")

  expected <- sprintf("# %s 1.0.0", project_name())
  expect_equal(contents[[2L]], expected)
})
