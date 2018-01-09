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
  ## curl::parse_headers_list() calls trimws()
  ## https://github.com/jeroen/curl/issues/138
  skip_if(getRversion() < 3.2)
  with_mock(
    `usethis:::check_host` = function(url) NULL,
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
      "attachment; filename=\"foo.zip\"; filename*=UTF-8''foo.zip\""
    ),
    c(
      "filename" = "\"foo.zip\"",
      "filename*" = "UTF-8''foo.zip\""
    )
  )
  ## typical GitHub
  expect_identical(
    parse_content_disposition("attachment; filename=foo-master.zip"),
    c("filename" = "foo-master.zip")
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

## https://github.com/parshap/node-sanitize-filename/blob/master/test.js
test_that("sanitize_filename() catches obviously bad filenames", {
  expect_identical(sanitize_filename(""), "")

  ## should drop dirname(input)
  expect_identical(sanitize_filename("../foo"), "foo")

  ## Joe scaring me into filename sanitization
  expect_identical(sanitize_filename("~/.ssh/id_rsa"), "id_rsa")

  ## ".." and "."
  expect_identical(sanitize_filename(".."), "_")
  expect_identical(sanitize_filename("."), "_")

  ## combine ".." and "." with "/"
  expect_identical(sanitize_filename("./"), "_")
  expect_identical(sanitize_filename("../"), "_")
  expect_identical(sanitize_filename("/.."), "_")
  expect_identical(sanitize_filename("/../"), "_")

  ## percent encoding of reserved and non-ascii characters
  expect_identical(sanitize_filename("spaces happen.mp3"), "spaces%20happen.mp3")
  expect_identical(sanitize_filename("spaces happen  "), "spaces%20happen%20%20")
  expect_identical(sanitize_filename("résumé"), "r%C3%A9sum%C3%A9")
  expect_identical(sanitize_filename("a\u0001b"), "a%01b")
  expect_identical(sanitize_filename("a\x01b"), "a%01b")
  expect_identical(sanitize_filename("a\nb"), "a%0Ab")
  expect_true(
    sanitize_filename("a\\b") == "a%5Cb" || # not Windows
      sanitize_filename("a\\b") == "b"      # Windows
  )
  expect_identical(sanitize_filename("a?b"), "a%3Fb")
  expect_identical(sanitize_filename("a*b"), "a%2Ab")
  expect_identical(sanitize_filename("a:b"), "a%3Ab")
  expect_identical(sanitize_filename("a|b"), "a%7Cb")
  expect_identical(sanitize_filename("a\"b"), "a%22b")
  expect_identical(sanitize_filename("a<b"), "a%3Cb")
  expect_identical(sanitize_filename("a>b"), "a%3Eb")

  ## non-trailing dots
  expect_identical(sanitize_filename("a.b"), "a.b")
  expect_identical(sanitize_filename("a.b.c"), "a.b.c")
  expect_identical(sanitize_filename(".a"), ".a")
  expect_identical(sanitize_filename(".a.b"), ".a.b")

  ## trailing dots and spaces are not OK on Windows
  expect_identical(sanitize_filename("a."), "a_")
  expect_identical(sanitize_filename("a.."), "a_")
  expect_identical(sanitize_filename("a.b."), "a.b_")

  ## Windows reserved names (or not!)
  expect_identical(sanitize_filename("con"), "_")
  expect_identical(sanitize_filename("constant"), "constant")
  expect_identical(sanitize_filename("COM1"), "_")
  expect_identical(sanitize_filename("TELECOMMUNICATIONS"), "TELECOMMUNICATIONS")
  expect_identical(sanitize_filename("PRN."), "_")
  expect_identical(sanitize_filename("aux.txt"), "_")
  expect_identical(sanitize_filename("LPT9.asdfasdf"), "_")
  expect_identical(sanitize_filename("LPT10.txt"), "LPT10.txt")
})
