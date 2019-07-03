## tidy_download ----

test_that("tidy_download() errors early if destdir is not a directory", {
  tmp <- fs::path_temp("I_am_just_a_file")
  expect_error(
    tidy_download("URL", destdir = tmp), "does not exist",
    class = "usethis_error"
  )

  fs::file_create(tmp)
  expect_error(
    tidy_download("URL", destdir = tmp), "not a directory",
    class = "usethis_error"
  )
})

test_that("tidy_download() works", {
  skip_on_cran()
  skip_if_offline()

  tmp <- fs::file_temp("tidy-download-test-")
  fs::dir_create(tmp)
  on.exit(fs::dir_delete(tmp))

  gh_url <- "https://github.com/r-lib/rematch2/archive/master.zip"
  expected <- fs::path(tmp, "rematch2-master.zip")

  out <- tidy_download(gh_url, destdir = tmp)
  expect_true(fs::file_exists(expected))
  expect_equivalent(out, expected)
  expect_identical(attr(out, "content-type"), "application/zip")

  # refuse to overwrite when non-interactive
  expect_error(tidy_download(gh_url, destdir = tmp))
})

## tidy_unzip ----

test_that("tidy_unzip() deals with loose parts, reports unpack destination", {
  tmp <- file_temp(ext = ".zip")
  fs::file_copy(test_file("yo-loose-regular.zip"), tmp)
  dest <- tidy_unzip(tmp)
  loose_regular_files <- fs::path_file(fs::dir_ls(dest, recurse = TRUE))
  fs::dir_delete(dest)

  tmp <- file_temp(ext = ".zip")
  fs::file_copy(test_file("yo-loose-dropbox.zip"), tmp)
  dest <- tidy_unzip(tmp)
  loose_dropbox_files <- fs::path_file(fs::dir_ls(dest, recurse = TRUE))
  fs::dir_delete(dest)

  tmp <- file_temp(ext = ".zip")
  fs::file_copy(test_file("yo-not-loose.zip"), tmp)
  dest <- tidy_unzip(tmp)
  not_loose_files <- fs::path_file(fs::dir_ls(dest, recurse = TRUE))
  fs::dir_delete(dest)

  expect_identical(loose_regular_files, loose_dropbox_files)
  expect_identical(loose_dropbox_files, not_loose_files)
})

## helpers ----
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

test_that("shortlinks pass through", {
  url1 <- "bit.ly/usethis-shortlink-example"
  url2 <- "rstd.io/usethis-shortlink-example"
  expect_equal(normalize_url(url1), paste0("https://", url1))
  expect_equal(normalize_url(url2), paste0("https://", url2))
  expect_equal(normalize_url(paste0("https://", url1)), paste0("https://", url1))
  expect_equal(normalize_url(paste0("http://", url1)), paste0("http://", url1))
})

test_that("github links get expanded", {
  expect_equal(
    normalize_url("OWNER/REPO"),
    "https://github.com/OWNER/REPO/archive/master.zip"
  )
})

test_that("conspicuous_place() returns a writeable directory", {
  expect_error_free(x <- conspicuous_place())
  expect_true(is_dir(x))
  expect_true(file_access(x, mode = "write"))
})

test_that("check_is_zip() errors if MIME type is not 'application/zip'", {
  skip("work this into a use_course test")
  skip_on_cran()
  skip_if_offline()
  expect_usethis_error(
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
