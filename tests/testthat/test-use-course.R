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
  expect_equivalent(file.access(x, mode = 2), 0L)
})

test_that("check_is_zip() errors if MIME type is not 'application/zip'", {
  ## download timed out on a CRAN submission, so let's not take a chance
  skip_on_cran()
  ## curl::parse_headers_list() calls trimws()
  ## https://github.com/jeroen/curl/issues/138
  skip_if(getRversion() < 3.2)
  expect_error(
    download_zip(
      "https://cran.r-project.org/src/contrib/rematch2_2.0.1.tar.gz"
    ),
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

## mostly inspired by
## https://github.com/parshap/node-sanitize-filename/blob/master/test.js
test_that("sanitize_filename() catches obviously bad filenames", {
  ## between R 3.1.3 and 3.2.5, the casing of hexadecimal used when percent-
  ## encoding in `URLencode()` changed
  ## R 3.1.3           URLencode("a\nb") returns "a%0ab"
  ## R 3.2.5 and later URLencode("a\nb") returns "A%0Ab"
  ## hence these helpers
  hex_case <- function(x) gsub("(%[[:xdigit:]]{2})", "\\U\\1", x, perl = TRUE)
  expect_same <- function(x, y) expect_identical(hex_case(x), y)
  expect_identical(hex_case("aa%aabb"), "aa%AAbb")

  expect_same(sanitize_filename(""), "")

  ## should drop dirname(input)
  expect_same(sanitize_filename("../foo"), "foo")

  ## Joe scaring me into filename sanitization
  expect_same(sanitize_filename("~/.ssh/id_rsa"), "id_rsa")

  ## ".." and "."
  expect_same(sanitize_filename(".."), "_")
  expect_same(sanitize_filename("."), "_")

  ## combine ".." and "." with "/"
  expect_same(sanitize_filename("./"), "_")
  expect_same(sanitize_filename("../"), "_")
  expect_same(sanitize_filename("/.."), "_")
  expect_same(sanitize_filename("/../"), "_")

  ## percent encoding of reserved and non-ascii characters
  expect_same(sanitize_filename("spaces happen.mp3"), "spaces%20happen.mp3")
  expect_same(sanitize_filename("spaces happen  "), "spaces%20happen%20%20")
  expect_same(sanitize_filename("résumé"), "r%C3%A9sum%C3%A9")
  expect_same(sanitize_filename("a\u0001b"), "a%01b")
  expect_same(sanitize_filename("a\x01b"), "a%01b")
  expect_same(sanitize_filename("a\nb"), "a%0Ab")
  expect_true(
    hex_case(sanitize_filename("a\\b")) == "a%5Cb" || # not Windows
      hex_case(sanitize_filename("a\\b")) == "b"      # Windows
  )
  expect_same(sanitize_filename("a?b"), "a%3Fb")
  expect_same(sanitize_filename("a*b"), "a%2Ab")
  expect_same(sanitize_filename("a:b"), "a%3Ab")
  expect_same(sanitize_filename("a|b"), "a%7Cb")
  expect_same(sanitize_filename("a\"b"), "a%22b")
  expect_same(sanitize_filename("a<b"), "a%3Cb")
  expect_same(sanitize_filename("a>b"), "a%3Eb")

  ## non-trailing dots
  expect_same(sanitize_filename("a.b"), "a.b")
  expect_same(sanitize_filename("a.b.c"), "a.b.c")
  expect_same(sanitize_filename(".a"), ".a")
  expect_same(sanitize_filename(".a.b"), ".a.b")

  ## trailing dots are not OK on Windows
  ## (neither are trailing spaces, but they'll have been percent-encoded)
  expect_same(sanitize_filename("a."), "a_")
  expect_same(sanitize_filename("a.."), "a_")
  expect_same(sanitize_filename("a.b."), "a.b_")

  ## Windows reserved names (or not!)
  expect_same(sanitize_filename("con"), "_")
  expect_same(sanitize_filename("constant"), "constant")
  expect_same(sanitize_filename("COM1"), "_")
  expect_same(sanitize_filename("TELECOMMUNICATIONS"), "TELECOMMUNICATIONS")
  expect_same(sanitize_filename("PRN."), "_")
  expect_same(sanitize_filename("aux.txt"), "_")
  expect_same(sanitize_filename("LPT9.asdfasdf"), "_")
  expect_same(sanitize_filename("LPT10.txt"), "LPT10.txt")
})

test_that("keep() keeps and drops correct files", {
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
  tmp <- tempfile(fileext = ".zip")
  file.copy(test_file("yo-loose-regular.zip"), tmp)
  capture_output(dest <- tidy_unzip(tmp))
  loose_regular_files <- list.files(dest, recursive = TRUE)

  tmp <- tempfile(fileext = ".zip")
  file.copy(test_file("yo-loose-dropbox.zip"), tmp)
  capture_output(dest <- tidy_unzip(tmp))
  loose_dropbox_files <- list.files(dest, recursive = TRUE)

  tmp <- tempfile(fileext = ".zip")
  file.copy(test_file("yo-not-loose.zip"), tmp)
  capture_output(dest <- tidy_unzip(tmp))
  not_loose_files <- list.files(dest, recursive = TRUE)

  expect_identical(loose_regular_files, loose_dropbox_files)
  expect_identical(loose_dropbox_files, not_loose_files)
})
