# use_package() guides new packages but not pre-existing ones

    Code
      use_package("withr")
    Message <message>
      v Adding 'withr' to Imports field in DESCRIPTION
      * Refer to functions with `withr::fun()`
    Code
      use_package("withr")
    Message <message>
      * Refer to functions with `withr::fun()`
    Code
      use_package("withr", "Suggests")
    Warning <simpleWarning>
      Package 'withr' is already listed in 'Imports' in DESCRIPTION, no change made.

