test_that("code_hint_with_host() works", {

  expect_identical(code_hint_with_host("foo"), "foo()")
  expect_identical(code_hint_with_host("foo", arg_name = "arg"), "foo()")

  host_github <- "https://api.github.com"
  expect_identical(code_hint_with_host("foo", host = host_github), "foo()")
  expect_identical(
    code_hint_with_host("foo", host = host_github, arg_name = "arg"),
    "foo()"
  )

  host_ghe <- "https://github.acme.com"
  expect_identical(
    code_hint_with_host("foo", host = host_ghe),
    'foo("https://github.acme.com")'
  )
  expect_identical(
    code_hint_with_host("foo", host = host_ghe, arg_name = "arg"),
    'foo(arg = \"https://github.acme.com\")'
  )
})
