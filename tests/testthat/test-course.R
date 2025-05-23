## download_url ----

test_that("download_url() retry logic works as advertised", {
  faux_download <- function(n_failures) {
    i <- 0
    function(url, destfile, quiet, mode, handle) {
      i <<- i + 1
      if (i <= n_failures) simpleError(paste0("try ", i)) else "success"
    }
  }
  withr::local_options(list(usethis.quiet = FALSE))

  # succeed on first try
  local_mocked_bindings(
    try_download = faux_download(0)
  )
  expect_snapshot(out <- download_url(url = "URL", destfile = "destfile"))
  expect_s3_class(out, "curl_handle")

  # fail, then succeed
  local_mocked_bindings(
    try_download = faux_download(1)
  )
  expect_snapshot(out <- download_url(url = "URL", destfile = "destfile"))
  expect_s3_class(out, "curl_handle")

  # fail, fail, then succeed (default n_tries = 3, so should allow)
  local_mocked_bindings(
    try_download = faux_download(2)
  )
  expect_snapshot(out <- download_url(url = "URL", destfile = "destfile"))
  expect_s3_class(out, "curl_handle")

  # fail, fail, fail (exceed n_failures > n_tries = 3)
  local_mocked_bindings(
    try_download = faux_download(5)
  )
  expect_snapshot(
    out <- download_url(url = "URL", destfile = "destfile", n_tries = 3),
    error = TRUE
  )

  # fail, fail, fail, succeed (make sure n_tries is adjustable)
  local_mocked_bindings(
    try_download = faux_download(3)
  )
  expect_snapshot(
    out <- download_url(url = "URL", destfile = "destfile", n_tries = 10)
  )
  expect_s3_class(out, "curl_handle")
})

## tidy_download ----

test_that("tidy_download() errors early if destdir is not a directory", {
  tmp <- fs::path_temp("I_am_just_a_file")
  withr::defer(fs::file_delete(tmp))

  expect_usethis_error(tidy_download("URL", destdir = tmp), "does not exist")

  fs::file_create(tmp)
  expect_usethis_error(tidy_download("URL", destdir = tmp), "not a directory")
})

test_that("tidy_download() works", {
  skip_if_offline("github.com")
  local_interactive(FALSE)

  tmp <- withr::local_tempdir(pattern = "tidy-download-test-")

  gh_url <- "https://github.com/r-lib/rematch2/archive/main.zip"
  expected <- fs::path(tmp, "rematch2-main.zip")

  capture.output(
    out <- tidy_download(gh_url, destdir = tmp)
  )
  expect_true(fs::file_exists(expected))
  expect_identical(out, expected, ignore_attr = TRUE)
  expect_identical(attr(out, "content-type"), "application/zip")

  # refuse to overwrite when non-interactive
  # snapshot impractical due to
  # (1) output beyond usethis's control re: download progress
  # (2) a temp file path that would need to be scrubbed (possible but won't
  #     bother due to (1))
  expect_usethis_error(tidy_download(gh_url, destdir = tmp))
})

## tidy_unzip ----

test_that("tidy_unzip(): explicit parent, file example", {
  local_interactive(FALSE)

  zipfile <- withr::local_tempfile(fileext = ".zip")
  file_copy(test_file("foo-explicit-parent.zip"), zipfile)
  dest <- tidy_unzip(zipfile)
  withr::defer(dir_delete(dest))
  expect_equal(path_file(dest), "foo")

  explicit_parent_files <- path_file(dir_ls(dest, recurse = TRUE))
  expect_equal(explicit_parent_files, "file.txt")
})

test_that("tidy_unzip(): explicit parent, folders example", {
  local_interactive(FALSE)
  files <- c("subdir1", "file1.txt", "subdir2", "file2.txt")

  zipfile <- withr::local_tempfile(fileext = ".zip")
  file_copy(test_file("yo-explicit-parent.zip"), zipfile)
  dest <- tidy_unzip(zipfile)
  withr::defer(dir_delete(dest))
  expect_equal(path_file(dest), "yo")

  explicit_parent_files <- path_file(dir_ls(dest, recurse = TRUE))
  expect_setequal(explicit_parent_files, files)
})

test_that("tidy_unzip(): implicit parent, file example", {
  local_interactive(FALSE)

  zipfile <- withr::local_tempfile(fileext = ".zip")
  file_copy(test_file("foo-implicit-parent.zip"), zipfile)
  dest <- tidy_unzip(zipfile)
  withr::defer(dir_delete(dest))
  expect_equal(path_file(dest), "foo")

  implicit_parent_files <- path_file(dir_ls(dest, recurse = TRUE))
  expect_equal(implicit_parent_files, "file.txt")
})

test_that("tidy_unzip(): implicit parent, folders example", {
  local_interactive(FALSE)
  files <- c("subdir1", "file1.txt", "subdir2", "file2.txt")

  zipfile <- withr::local_tempfile(fileext = ".zip")
  file_copy(test_file("yo-implicit-parent.zip"), zipfile)
  dest <- tidy_unzip(zipfile)
  withr::defer(dir_delete(dest))
  expect_equal(path_file(dest), "yo")

  implicit_parent_files <- path_file(dir_ls(dest, recurse = TRUE))
  expect_setequal(implicit_parent_files, files)
})

test_that("tidy_unzip(): no parent, file example", {
  local_interactive(FALSE)

  zipfile <- withr::local_tempfile(fileext = ".zip")
  file_copy(test_file("foo-no-parent.zip"), zipfile)
  dest <- tidy_unzip(zipfile)
  withr::defer(dir_delete(dest))
  expect_equal(path_file(dest), path_ext_remove(path_file(zipfile)))

  no_parent_files <- path_file(dir_ls(dest, recurse = TRUE))
  expect_setequal(no_parent_files, "file.txt")
})

test_that("tidy_unzip(): no parent, folders example", {
  local_interactive(FALSE)
  files <- c("subdir1", "file1.txt", "subdir2", "file2.txt")

  zipfile <- withr::local_tempfile(fileext = ".zip")
  file_copy(test_file("yo-no-parent.zip"), zipfile)
  dest <- tidy_unzip(zipfile)
  withr::defer(dir_delete(dest))
  expect_equal(path_file(dest), path_ext_remove(path_file(zipfile)))

  no_parent_files <- path_file(dir_ls(dest, recurse = TRUE))
  expect_setequal(no_parent_files, files)
})

test_that("tidy_unzip(): DropBox, file example", {
  local_interactive(FALSE)

  zipfile <- withr::local_tempfile(fileext = ".zip")
  file_copy(test_file("foo-loose-dropbox.zip"), zipfile)
  dest <- tidy_unzip(zipfile)
  withr::defer(dir_delete(dest))
  expect_equal(path_file(dest), path_ext_remove(path_file(zipfile)))

  loose_dropbox_files <- path_file(dir_ls(dest, recurse = TRUE))
  expect_setequal(loose_dropbox_files, "file.txt")
})

test_that("tidy_unzip(): DropBox, folders example", {
  local_interactive(FALSE)
  files <- c("subdir1", "file1.txt", "subdir2", "file2.txt")

  zipfile <- withr::local_tempfile(fileext = ".zip")
  file_copy(test_file("yo-loose-dropbox.zip"), zipfile)
  dest <- tidy_unzip(zipfile)
  withr::defer(dir_delete(dest))
  expect_equal(path_file(dest), path_ext_remove(path_file(zipfile)))

  loose_dropbox_files <- path_file(dir_ls(dest, recurse = TRUE))
  expect_setequal(loose_dropbox_files, files)
})

test_that("path_before_slash() works", {
  expect_equal(path_before_slash(""), "")
  expect_equal(path_before_slash("/"), "")
  expect_equal(path_before_slash("a/"), "a")
  expect_equal(path_before_slash("a/b"), "a")
  expect_equal(path_before_slash("a/b/c"), "a")
  expect_equal(path_before_slash("a/b/c/"), "a")
})

## helpers ----
test_that("create_download_url() works", {
  expect_equal(
    create_download_url("https://rstudio.com"),
    "https://rstudio.com"
  )
  expect_equal(
    create_download_url("https://drive.google.com/open?id=123456789xxyyyzzz"),
    "https://drive.google.com/uc?export=download&id=123456789xxyyyzzz"
  )
  expect_equal(
    create_download_url(
      "https://drive.google.com/file/d/123456789xxxyyyzzz/view"
    ),
    "https://drive.google.com/uc?export=download&id=123456789xxxyyyzzz"
  )
  expect_equal(
    create_download_url("https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=0"),
    "https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=1"
  )

  # GitHub
  usethis_url <- "https://github.com/r-lib/usethis/zipball/HEAD"
  expect_equal(
    create_download_url("https://github.com/r-lib/usethis"),
    usethis_url
  )
  expect_equal(
    create_download_url("https://github.com/r-lib/usethis/issues"),
    usethis_url
  )
  expect_equal(
    create_download_url("https://github.com/r-lib/usethis#readme"),
    usethis_url
  )
})

test_that("normalize_url() prepends https:// (or not)", {
  expect_snapshot(normalize_url(1), error = TRUE)
  expect_identical(normalize_url("http://bit.ly/abc"), "http://bit.ly/abc")
  expect_identical(normalize_url("bit.ly/abc"), "https://bit.ly/abc")
  expect_identical(
    normalize_url("https://github.com/r-lib/rematch2/archive/main.zip"),
    "https://github.com/r-lib/rematch2/archive/main.zip"
  )
  expect_identical(
    normalize_url("https://rstd.io/usethis-src"),
    "https://rstd.io/usethis-src"
  )
  expect_identical(
    normalize_url("rstd.io/usethis-src"),
    "https://rstd.io/usethis-src"
  )
})

test_that("shortlinks pass through", {
  url1 <- "bit.ly/usethis-shortlink-example"
  url2 <- "rstd.io/usethis-shortlink-example"
  expect_equal(normalize_url(url1), paste0("https://", url1))
  expect_equal(normalize_url(url2), paste0("https://", url2))
  expect_equal(
    normalize_url(paste0("https://", url1)),
    paste0("https://", url1)
  )
  expect_equal(normalize_url(paste0("http://", url1)), paste0("http://", url1))
})

test_that("github links get expanded", {
  expect_equal(
    normalize_url("OWNER/REPO"),
    "https://github.com/OWNER/REPO/zipball/HEAD"
  )
})

test_that("conspicuous_place() returns a writeable directory", {
  skip_on_cran_macos() # even $HOME is not writeable on CRAN macOS builder
  expect_no_error(x <- conspicuous_place())
  expect_true(is_dir(x))
  expect_true(file_access(x, mode = "write"))
})

test_that("conspicuous_place() uses `usethis.destdir` when set", {
  destdir <- withr::local_tempdir(pattern = "destdir_temp")
  withr::local_options(list(usethis.destdir = destdir))
  expect_no_error(x <- conspicuous_place())
  expect_equal(path_tidy(destdir), x)
})

test_that("use_course() errors if MIME type is not 'application/zip'", {
  skip_if_offline()

  path <- withr::local_tempdir()
  expect_usethis_error(
    use_course("https://example.com", destdir = path),
    "does not have MIME type"
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
    parse_content_disposition("attachment; filename=foo-main.zip"),
    c("filename" = "foo-main.zip")
  )
})

test_that("parse_content_disposition() errors on ill-formed `content-disposition` header", {
  expect_usethis_error(
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
    make_filename(c("filename" = "buzzy-main.zip")),
    "buzzy-main.zip"
  )
})

test_that("make_filename() uses fallback if no `content-disposition` header", {
  expect_match(make_filename(NULL), "^file[0-9a-z]+$")
})

test_that("keep_lgl() keeps and drops correct files", {
  keepers <- c("foo", ".gitignore", "a/.gitignore", "foo.Rproj", ".here")
  expect_true(all(keep_lgl(keepers)))

  droppers <- c(
    ".git",
    "/.git",
    "/.git/",
    ".git/",
    "foo/.git",
    ".git/config",
    ".git/objects/06/3d3gysle",
    ".Rproj.user",
    ".Rproj.user/123jkl/persistent-state",
    ".Rhistory",
    ".RData"
  )
  expect_false(any(keep_lgl(droppers)))
})
