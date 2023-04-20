# use_version() errors for invalid `which`

    Code
      use_version("1.2.3")
    Condition
      Error in `choose_version()`:
      ! `which` must be one of "major", "minor", "patch", or "dev", not "1.2.3".

