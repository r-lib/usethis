test_that("use_cpp11() requires a package", {
  create_local_project()
  expect_usethis_error(use_cpp11(), "not an R package")
})

test_that("use_cpp11() creates files/dirs, edits DESCRIPTION and .gitignore", {
  create_local_package()
  use_roxygen_md()
  use_package_doc() # needed for use_cpp11()

  # pretend cpp11 is installed
  local_check_installed()

  use_cpp11()
  expect_match(desc::desc_get("LinkingTo"), "cpp11")
  expect_proj_dir("src")
  expect_proj_file("src", "code.cpp")

  ignores <- read_utf8(proj_path("src", ".gitignore"))
  expect_contains(ignores, c("*.o", "*.so", "*.dll"))
})

test_that("check_cpp_register_deps is silent if all installed, emits todo if not", {
  withr::local_options(list(usethis.quiet = FALSE))
  local_mocked_bindings(
    get_cpp_register_deps = function() c("brio", "decor", "vctrs"),
    is_installed = function(package) TRUE
  )

  expect_no_message(
    check_cpp_register_deps()
  )

  local_mocked_bindings(
    is_installed = function(package) identical(package, "brio")
  )

  expect_snapshot(
    check_cpp_register_deps()
  )
})
