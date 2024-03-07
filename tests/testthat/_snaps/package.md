# use_package() guides new packages but not pre-existing ones

    Code
      use_package("withr")
    Message
      v Adding withr to 'Imports' field in DESCRIPTION.
      [ ] Refer to functions with `withr::fun()`.
    Code
      use_package("withr")
      use_package("withr", "Suggests")
    Message
      ! Package withr is already listed in 'Imports' in DESCRIPTION; no change made.

# use_package() handles R versions with aplomb

    Code
      use_package("R")
    Condition
      Error in `use_dependency()`:
      x Set `type = "Depends"` when specifying an R version.

---

    Code
      use_package("R", type = "Depends")
    Condition
      Error in `use_dependency()`:
      x Specify `min_version` when `package = "R"`.

---

    Code
      use_package("R", type = "Depends", min_version = "3.6")
    Message
      v Adding R to 'Depends' field in DESCRIPTION.

---

    Code
      use_package("R", type = "Depends", min_version = TRUE)
    Message
      v Increasing R version to ">= 4.1" in DESCRIPTION.

# use_package(type = 'Suggests') guidance w/o and w/ rlang

    Code
      use_package("withr", "Suggests")
    Message
      v Adding withr to 'Suggests' field in DESCRIPTION.
      [ ] Use `requireNamespace("withr", quietly = TRUE)` to test if withr is
        installed.
      [ ] Then directly refer to functions with `withr::fun()`.

---

    Code
      use_package("purrr", "Suggests")
    Message
      v Adding purrr to 'Suggests' field in DESCRIPTION.
      [ ] In your package code, use `rlang::is_installed("purrr")` or
        `rlang::check_installed("purrr")` to test if purrr is installed.
      [ ] Then directly refer to functions with `purrr::fun()`.

