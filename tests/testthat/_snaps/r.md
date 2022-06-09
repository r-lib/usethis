# use_r() creates a .R file below R/

    Code
      use_r("")
    Condition
      Error:
      ! Name must not be an empty string

# use_test() creates a test file

    Code
      use_test("", open = FALSE)
    Condition
      Error:
      ! Name must not be an empty string

