test_that("standalone_header() works with various inputs", {
  expect_snapshot(
    standalone_header("OWNER/REPO", "R/standalone-foo.R")
  )
  expect_snapshot(
    standalone_header("OWNER/REPO", "R/standalone-foo.R", ref = "blah")
  )
  expect_snapshot(
    standalone_header(
      "OWNER/REPO",
      "R/standalone-foo.R",
      host = "https://github.com"
    )
  )
  expect_snapshot(
    standalone_header(
      "OWNER/REPO",
      "R/standalone-foo.R",
      host = "https://github.acme.com"
    )
  )
  expect_snapshot(
    standalone_header(
      "OWNER/REPO",
      "R/standalone-foo.R",
      ref = "blah",
      host = "https://github.com"
    )
  )
  expect_snapshot(
    standalone_header(
      "OWNER/REPO",
      "R/standalone-foo.R",
      ref = "blah",
      host = "https://github.acme.com"
    )
  )
})

test_that("can import standalone file with dependencies", {
  skip_if_offline("github.com")
  create_local_package()

  # NOTE: Check ref after r-lib/rlang@standalone-dep has been merged
  use_standalone("r-lib/rlang", "types-check", ref = "73182fe94")
  expect_setequal(
    as.character(path_rel(dir_ls(proj_path("R"))), proj_path()),
    c("R/import-standalone-types-check.R", "R/import-standalone-obj-type.R")
  )

  desc <- proj_desc()
  imports <- proj_desc()$get_field("Imports")
  expect_length(imports, 1)
  expect_match(imports, "rlang")
})

test_that("can use full github url", {
  skip_if_offline("github.com")
  create_local_package()

  use_standalone(
    "https://github.com/r-lib/rlang",
    file = "sizes",
    ref = "4670cb233ecc8d11"
  )
  expect_equal(
    as.character(path_rel(dir_ls(proj_path("R"))), proj_path()),
    "R/import-standalone-sizes.R"
  )
})


test_that("can offer choices", {
  skip_if_offline("github.com")

  expect_snapshot(error = TRUE, {
    standalone_choose("tidyverse/forcats", ref = "v1.0.0")
    standalone_choose("r-lib/rlang", ref = "4670cb233ecc8d11")
  })
})

test_that("can extract dependencies", {
  extract_deps <- function(deps) {
    out <- standalone_dependencies(c("# ---", deps, "# ---"), "test.R")
    out$deps
  }

  expect_equal(extract_deps(NULL), character())
  expect_equal(extract_deps("# dependencies: a"), "a")
  expect_equal(extract_deps("# dependencies: [a, b]"), c("a", "b"))
})

test_that("can extract imports", {
  extract_imports <- function(imports) {
    out <- standalone_dependencies(
      c("# ---", imports, "# ---"),
      "test.R",
      error_call = current_env()
    )
    out$imports
  }

  expect_equal(
    extract_imports(NULL),
    version_info_df()
  )

  expect_equal(
    extract_imports("# imports: rlang"),
    version_info_df("rlang", NA, NA)
  )

  expect_equal(
    extract_imports("# imports: rlang (>= 1.0.0)"),
    version_info_df("rlang", ">=", "1.0.0")
  )

  expect_equal(
    extract_imports("# imports: [rlang (>= 1.0.0), purrr]"),
    version_info_df(c("rlang", "purrr"), c(">=", NA), c("1.0.0", NA))
  )

  expect_snapshot(error = TRUE, {
    extract_imports("# imports: rlang (== 1.0.0)")
    extract_imports("# imports: rlang (>= 1.0.0), purrr")
    extract_imports("# imports: foo (>=0.0.0)")
  })
})

test_that("errors on malformed dependencies", {
  expect_snapshot(error = TRUE, {
    standalone_dependencies(c(), "test.R")
    standalone_dependencies(c("# ---", "# dependencies: 1", "# ---"), "test.R")
  })
})

test_that("standalone file is normalised", {
  expect_equal(as_standalone_file("foo"), "standalone-foo.R")
  expect_equal(as_standalone_file("standalone-foo"), "standalone-foo.R")
  expect_equal(as_standalone_file("standalone-foo.R"), "standalone-foo.R")
  expect_equal(as_standalone_file("aaa-standalone-foo"), "aaa-standalone-foo.R")
  expect_equal(
    as_standalone_file("aaa-standalone-foo.R"),
    "aaa-standalone-foo.R"
  )
})

test_that("standalone destination file is normalised", {
  expect_equal(
    as_standalone_dest_file("standalone-foo.R"),
    "import-standalone-foo.R"
  )
  expect_equal(
    as_standalone_dest_file("aaa-standalone-foo.R"),
    "aaa-import-standalone-foo.R"
  )
})
