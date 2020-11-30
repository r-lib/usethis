test_that("get_ui_code_hint() works", {

  host_github <- "https://api.github.com"

  # no argument if github
  expect_identical(
    get_ui_code_hint("foo::bar", host_github),
    ui_code('foo::bar()')
  )

  expect_identical(
    get_ui_code_hint("foo::bar", host_github, arg_name = "arg"),
    ui_code('foo::bar()')
  )

  # argument if enterprise
  expect_identical(
    get_ui_code_hint("foo::bar", "https://github.acme.com"),
    ui_code('foo::bar("https://github.acme.com")')
  )

  expect_identical(
    get_ui_code_hint("foo::bar", "https://github.acme.com", arg_name = "arg"),
    ui_code('foo::bar(arg = "https://github.acme.com")')
  )
})
