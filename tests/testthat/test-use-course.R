context("use_course")

test_that("normalize_url() prepends https:// (or not)", {
  expect_error(normalize_url(1), "is\\.character.*not TRUE")
  expect_identical(normalize_url("http://bit.ly/aaa"), "http://bit.ly/aaa")
  expect_identical(normalize_url("bit.ly/aaa"), "https://bit.ly/aaa")
  expect_identical(
    normalize_url("https://github.com/r-lib/rematch2/archive/master.zip"),
    "https://github.com/r-lib/rematch2/archive/master.zip"
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

test_that("conspicuous_place() returns a writeable directory", {
  expect_error_free(x <- conspicuous_place())
  expect_true(is_dir(x))
  expect_true(file_access(x, mode = "write"))
})

test_that("check_is_zip() errors if MIME type is not 'application/zip'", {
  skip_if_offline()
  ## download timed out on a CRAN submission, so let's not take a chance
  skip_on_cran()
  ## curl::parse_headers_list() calls trimws()
  ## curl got an internal trimws() backport in v3.2
  ## yes the version numbers for R and curl are just a coincidence
  skip_if(getRversion() < 3.2 && packageVersion("curl") < 3.2)

  expect_error(
    download_zip("https://httpbin.org/get"),
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

test_that("keep_lgl() keeps and drops correct files", {
  keepers <- c("foo", ".gitignore", "a/.gitignore", "foo.Rproj", ".here")
  expect_true(all(keep_lgl(keepers)))

  droppers <- c(
    ".git", "/.git", "/.git/", ".git/", "foo/.git",
    ".git/config", ".git/objects/06/3d3gysle",
    ".Rproj.user", ".Rproj.user/123jkl/persistent-state",
    ".Rhistory", ".RData"
  )
  expect_false(any(keep_lgl(droppers)))
})

test_that("top_directory() identifies a unique top directory (or not)", {
  ## there is >= 1 file at top-level or >1 directories
  expect_identical(top_directory("a"), NA_character_)
  expect_identical(top_directory(c("a/", "b")), NA_character_)
  expect_identical(top_directory(c("a/", "b/")), NA_character_)

  ## there are no files at top-level and exactly 1 directory
  expect_identical(top_directory("a/"), "a/")
  expect_identical(top_directory(c("a/", "a/b")), "a/")
  expect_identical(top_directory(c("a/", "a/b", "a/c")), "a/")
})

test_that("tidy_unzip() deals with loose parts, reports unpack destination", {
  tmp <- file_temp(ext = ".zip")
  file_copy(test_file("yo-loose-regular.zip"), tmp)
  dest <- tidy_unzip(tmp)
  loose_regular_files <- path_file(dir_ls(dest, recursive = TRUE))
  dir_delete(dest)

  tmp <- file_temp(ext = ".zip")
  file_copy(test_file("yo-loose-dropbox.zip"), tmp)
  dest <- tidy_unzip(tmp)
  loose_dropbox_files <- path_file(dir_ls(dest, recursive = TRUE))
  dir_delete(dest)

  tmp <- file_temp(ext = ".zip")
  file_copy(test_file("yo-not-loose.zip"), tmp)
  dest <- tidy_unzip(tmp)
  not_loose_files <- path_file(dir_ls(dest, recursive = TRUE))
  dir_delete(dest)

  expect_identical(loose_regular_files, loose_dropbox_files)
  expect_identical(loose_dropbox_files, not_loose_files)
})
