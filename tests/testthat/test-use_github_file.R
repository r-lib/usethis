test_that("parse_file_url() works when it should", {
  expect_equal(
    parse_file_url("https://github.com/OWNER/REPO/blob/REF/path/to/some/file"),
    list(
      parsed = TRUE, repo_spec = "OWNER/REPO", path = "path/to/some/file",
      ref = "REF", host = "https://github.com"
    )
  )
  expect_equal(
    parse_file_url("https://github.com/OWNER/REPO/blob/REF/path/to/some/file"),
    parse_file_url("https://raw.githubusercontent.com/OWNER/REPO/REF/path/to/some/file")
  )

  expect_equal(
    parse_file_url("https://github.com/OWNER/REPO/blob/REF/file"),
    list(
      parsed = TRUE, repo_spec = "OWNER/REPO", path = "file",
      ref = "REF", host = "https://github.com"
    )
  )
  expect_equal(
    parse_file_url("https://github.com/OWNER/REPO/blob/REF/file"),
    parse_file_url("https://raw.githubusercontent.com/OWNER/REPO/REF/file")
  )
})

test_that("parse_file_url() gives up when it should", {
  out <- parse_file_url("OWNER/REPO")
  expect_false(out$parsed)
})

test_that("parse_file_url() errors when it should", {
  expect_error(parse_file_url("https://github.com/OWNER/REPO"))
  expect_error(parse_file_url("https://github.com/OWNER/REPO.git"))

  expect_error(parse_file_url("https://gitlab.com/OWNER/REPO/path/to/file"))
})
