context("use_course")

test_that("check_host() screens for DropBox and GitHub .zip download URLs", {
  expect_error_free(check_host(
    "https://dl.dropboxusercontent.com/content_link_zip/12345/file"
  ))
  expect_error_free(check_host(
    "https://codeload.github.com/USER/REPO/zip/master"
  ))

  ## a regular sharing link for a folder
  expect_error(check_host(
    "https://www.dropbox.com/sh/12345/67890?dl=0",
    "URL has unrecognized form"
  ))
  ## GitHub URLs: browser, ssh, https
  expect_error(
    check_host("https://github.com/USER/REPO"),
    "URL has unrecognized form"
  )
  expect_error(
    check_host("git@github.com:USER/REPO.git"),
    "URL has unrecognized form"
  )
  expect_error(
    check_host("https://github.com/USER/REPO.git"),
    "URL has unrecognized form"
  )
})

test_that("check_is_zip() errors if MIME type is not 'application/zip'", {
  with_mock(
    check_host = function(url) NULL,
    expect_error(
      download_zip(
        "https://cran.r-project.org/src/contrib/rematch2_2.0.1.tar.gz"
      ),
      "does not have MIME type"
    )
  )
})

test_that("parse_content_disposition() parses Content-Description", {
  ## typical DropBox
  expect_identical(
    parse_content_disposition(
      "attachment; filename=\"usethis-test.zip\"; filename*=UTF-8''usethis-test.zip\""
    ),
    c(
      "filename" = "\"usethis-test.zip\"",
      "filename*" = "UTF-8''usethis-test.zip\""
    )
  )
  ## typical GitHub
  expect_identical(
    parse_content_disposition("attachment; filename=buzzy-master.zip"),
    c("filename" = "buzzy-master.zip")
  )
})

test_that("parse_content_disposition() errors on ill-formed `content-disposition` header", {
  expect_error(
    parse_content_disposition("aa;bb=cc;dd"),
    "doesn't start with"
  )
})

test_that("make_filename() gets name from `content-disposition` header", {
  ## DropBox
  expect_identical(
    make_filename(
      c(
        "filename" = "\"usethis-test.zip\"",
        "filename*" = "UTF-8''usethis-test.zip\""
      )
    ),
    "usethis-test.zip"
  )
  ## GitHub
  expect_identical(
    make_filename(c("filename" = "buzzy-master.zip")),
    "buzzy-master.zip"
  )
})

test_that("make_filename() uses fallback if no `content-disposition` header", {
  expect_match(make_filename(NULL), "^file[0-9a-z]+$")
})
