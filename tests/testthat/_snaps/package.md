# use_package() guides new packages but not pre-existing ones

    Code
      use_package("withr")
    Message <rlang_message>
      v Adding 'withr' to Imports field in DESCRIPTION
      * Refer to functions with `withr::fun()`
    Code
      use_package("withr")
    Message <rlang_message>
      * Refer to functions with `withr::fun()`
    Code
      use_package("withr", "Suggests")
    Warning <simpleWarning>
      Package 'withr' is already listed in 'Imports' in DESCRIPTION, no change made.

# use_package() handles R versions with aplomb

    Code
      use_package("R")
    Condition
      Error:
      ! Set `type = "Depends"` when specifying an R version

---

    Code
      use_package("R", type = "Depends")
    Condition
      Error:
      ! Specify `min_version` when `package = "R"`

---

    Code
      use_package("R", type = "Depends", min_version = "3.6")
    Message
      v Adding 'R' to Depends field in DESCRIPTION

---

    Code
      use_package("R", type = "Depends", min_version = TRUE)
    Message
      v Increasing 'R' version to '>= 4.1' in DESCRIPTION

