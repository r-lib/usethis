# use_dependency() declines to downgrade a dependency

    Code
      use_dependency("usethis", "Suggests")
    Message
      ! Package usethis is already listed in Imports in DESCRIPTION; no change made.

# can add LinkingTo dependency if other dependency already exists

    Code
      use_dependency("rlang", "LinkingTo")
    Message
      v Adding 'rlang' to LinkingTo field in DESCRIPTION

# use_dependency() does not fall over on 2nd LinkingTo request

    Code
      use_dependency("rlang", "LinkingTo")

# use_dependency() can level up a LinkingTo dependency

    Code
      use_package("rlang")
    Message
      v Moving 'rlang' from Suggests to Imports field in DESCRIPTION
      * Refer to functions with `rlang::fun()`

