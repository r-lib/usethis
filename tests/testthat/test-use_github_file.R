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

test_that("is_binary_file() detects binary files", {
  text <- withr::local_tempfile()
  writeLines("hello", text)
  expect_identical(is_binary_file(text), FALSE)

  binary <- withr::local_tempfile()
  writeBin(as.raw(c(0x89, 0x50, 0x00, 0x47)), binary)
  expect_identical(is_binary_file(binary), TRUE)
})

test_that("use_github_file() respects overwrite for binary files", {
  create_local_project()
  local_interactive(FALSE)

  tf <- withr::local_tempfile()
  writeBin(as.raw(1:4), tf)
  local_mocked_bindings(get_github_file = function(...) tf)

  bf <- proj_path("binary.file")
  writeBin(as.raw(5:8), bf)

  expect_identical(use_github_file("OWNER/REPO", path = "binary.file"), FALSE)
  expect_identical(readBin(bf, "raw", 4), as.raw(5:8))

  expect_identical(
    use_github_file("OWNER/REPO", path = "binary.file", overwrite = TRUE),
    TRUE
  )
  expect_identical(readBin(bf, "raw", 4), as.raw(1:4))
})

test_that("use_github_file works with non-text files", {
  skip_if_offline("github.com")
  create_local_project()
  use_github_file(
    "https://github.com/r-lib/usethis/blob/main/man/figures/logo.png",
    save_as = "logo.png"
  )

  expect_proj_file("logo.png")
})
