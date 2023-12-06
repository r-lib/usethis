test_that("use_cpp11() requires a package", {
  create_local_project()
  local_check_installed()
  expect_usethis_error(use_cpp11(), "not an R package")
})

test_that("use_cpp11() creates files/dirs, edits DESCRIPTION and .gitignore", {
  create_local_package()
  use_roxygen_md()
  use_package_doc()

  local_interactive(FALSE)
  local_check_installed()
  local_mocked_bindings(
    check_cpp_register_deps = function() invisible()
    # project_name = function() "testpkg"
  )

  use_cpp11()

  deps <- proj_deps()
  expect_equal(deps$type, "LinkingTo")
  expect_equal(deps$package, "cpp11")
  expect_proj_dir("src")

  ignores <- read_utf8(proj_path("src", ".gitignore"))
  expect_contains(ignores, c("*.o", "*.so", "*.dll"))

  namespace <- read_utf8(proj_path("NAMESPACE"))
  expect_match(namespace, "useDynLib", all = FALSE)
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
