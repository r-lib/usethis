test_that("use_cpp11() requires a package", {
  create_local_project()
  expect_usethis_error(use_cpp11(), "not an R package")
})

test_that("use_cpp11() creates files/dirs, edits DESCRIPTION and .gitignore", {
  create_local_package()
  use_roxygen_md()

  local_interactive(FALSE)
  with_mock(
    # Required to pass the check re: whether cpp11 is installed
    check_installed = function(pkg) TRUE,
    check_cpp_register_deps = function() invisible(),
    use_cpp11()
  )

  expect_match(desc::desc_get("LinkingTo"), "cpp11")
  expect_proj_dir("src")

  ignores <- read_utf8(proj_path("src", ".gitignore"))
  expect_true(all(c("*.o", "*.so", "*.dll") %in% ignores))
})

test_that("check_cpp_register_deps is silent if all installed, emits todo if not", {
  withr::local_options(list(usethis.quiet = FALSE))

  with_mock(
    get_cpp_register_deps = function() c("brio", "decor", "vctrs"),
    is_installed = function(pkg) TRUE,
    expect_silent(
      check_cpp_register_deps()
    )
  )

  with_mock(
    get_cpp_register_deps = function() c("brio", "decor", "vctrs"),
    is_installed = function(pkg) pkg == "brio",
    expect_message(
      check_cpp_register_deps(),
      "Now install"
    )
  )
})
