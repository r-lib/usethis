# use_package() guides new packages but not pre-existing ones

    Code
      use_package("withr")
    Message
      v Adding 'withr' to Imports field in DESCRIPTION
      * Refer to functions with `withr::fun()`
    Code
      use_package("withr")
    Message
      * Refer to functions with `withr::fun()`
    Code
      use_package("withr", "Suggests")
    Condition
      Warning:
      Package 'withr' is already listed in 'Imports' in DESCRIPTION, no change made.

# use_package(type = 'Suggests') guidance w/o and w/ rlang

    Code
      use_package("withr", "Suggests")
    Message
      v Adding 'withr' to Suggests field in DESCRIPTION
      * Use `requireNamespace("withr", quietly = TRUE)` to test if package is installed
      * Then directly refer to functions with `withr::fun()`

---

    Code
      use_package("purrr", "Suggests")
    Message
      v Adding 'purrr' to Suggests field in DESCRIPTION
      * In your package code, use `rlang::is_installed("purrr")` or `rlang::check_installed("purrr")` to test if purrr is installed
      * Then directly refer to functions with `purrr::fun()`

