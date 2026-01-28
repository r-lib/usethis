test_that("use_s7() requires a package", {
  create_local_project()
  expect_usethis_error(use_s7(), "not an R package")
})

test_that("use_s7() edits zzz.R and DESCRIPTION", {
  create_local_package()
  use_roxygen_md()
  use_package_doc()
  use_template("zzz.R", "R/zzz.R")

  use_s7()

  expect_match(desc::desc_get("Imports"), "S7")
  expect_proj_file("R", "zzz.R")

  zzz_contents <- read_utf8(proj_path("R", "zzz.R"))
  expect_true(any(grepl("S7::methods_register\\(\\)", zzz_contents)))
  expect_false(any(grepl("^\\s*#\\s*S7::methods_register", zzz_contents)))
})

test_that("use_s7() adds rawNamespace directive when backwards_compat = TRUE", {
  create_local_package()
  use_roxygen_md()
  use_package_doc()
  use_template("zzz.R", "R/zzz.R")

  use_s7(backwards_compat = TRUE)

  ns_show <- roxygen_ns_show()
  expect_true(any(grepl("@rawNamespace", ns_show)))
  expect_true(any(grepl('importFrom\\("S7", "@"\\)', ns_show)))
})

test_that("use_s7() skips rawNamespace when backwards_compat = FALSE", {
  create_local_package()
  use_roxygen_md()
  use_package_doc()
  use_template("zzz.R", "R/zzz.R")

  local_interactive(FALSE)
  local_mocked_bindings(
    ui_yep = function(...) TRUE
  )

  use_s7(backwards_compat = FALSE)

  ns_show <- roxygen_ns_show()
  expect_false(any(grepl("@rawNamespace", ns_show)))
})

test_that("use_s7() can be called twice without changing zzz.R", {
  create_local_package()
  use_roxygen_md()
  use_package_doc()
  use_template("zzz.R", "R/zzz.R")

  local_interactive(FALSE)
  local_mocked_bindings(
    ui_yep = function(...) TRUE
  )

  use_s7()
  zzz_before <- read_utf8(proj_path("R", "zzz.R"))

  use_s7()
  zzz_after <- read_utf8(proj_path("R", "zzz.R"))

  expect_identical(zzz_before, zzz_after)
})

test_that("use_zzz() does nothing if zzz.R already exists", {
  create_local_package()

  write_utf8(
    proj_path("R", "zzz.R"),
    ".onLoad <- function(libname, pkgname) {}"
  )

  result <- use_zzz()
  expect_false(result)
})

test_that("ensure_s7_methods_register() prompts if file differs from template", {
  create_local_package()
  local_interactive(FALSE)

  # if the zzz.R differes from the template we need to promp
  write_utf8(
    proj_path("R", "zzz.R"),
    c(
      ".onLoad <- function(libname, pkgname) {",
      "  cat('hello, world!')",
      "}"
    )
  )
  expect_error(use_s7())
})
