test_that("parse_file_url() works when it should", {
  expected <- list(
    parsed = TRUE,
    repo_spec = "OWNER/REPO",
    path = "path/to/some/file",
    ref = "REF",
    host = "https://github.com"
  )
  expect_equal(
    parse_file_url("https://github.com/OWNER/REPO/blob/REF/path/to/some/file"),
    expected
  )
  expect_equal(
    parse_file_url(
      "https://raw.githubusercontent.com/OWNER/REPO/REF/path/to/some/file"
    ),
    expected
  )

  expected$path <- "file"
  expect_equal(
    parse_file_url("https://github.com/OWNER/REPO/blob/REF/file"),
    expected
  )
  expect_equal(
    parse_file_url("https://github.com/OWNER/REPO/blob/REF/file"),
    parse_file_url("https://raw.githubusercontent.com/OWNER/REPO/REF/file")
  )

  expected$host <- "https://github.acme.com"
  expect_equal(
    parse_file_url("https://github.acme.com/OWNER/REPO/blob/REF/file"),
    expected
  )
  expect_equal(
    parse_file_url("https://raw.github.acme.com/OWNER/REPO/REF/file"),
    expected
  )
})

test_that("parse_file_url() gives up when it should", {
  out <- parse_file_url("OWNER/REPO")
  expect_false(out$parsed)
})

test_that("parse_file_url() errors when it should", {
  expect_usethis_error(parse_file_url("https://github.com/OWNER/REPO"))
  expect_usethis_error(parse_file_url("https://github.com/OWNER/REPO.git"))
  expect_usethis_error(parse_file_url(
    "https://github.com/OWNER/REPO/commit/abcdefg"
  ))
  expect_usethis_error(parse_file_url(
    "https://github.com/OWNER/REPO/releases/tag/vx.y.z"
  ))
  expect_usethis_error(parse_file_url(
    "https://github.com/OWNER/REPO/tree/BRANCH"
  ))
  expect_usethis_error(parse_file_url(
    "https://gitlab.com/OWNER/REPO/path/to/file"
  ))
})

test_that("use_github_file works with non-text files", {
  create_local_project()
  use_github_file(
    "https://github.com/r-lib/usethis/blob/main/man/figures/logo.png",
    save_as = "logo.png"
  )

  expect_proj_file("logo.png")
})
