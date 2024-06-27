# use_vignette() gives useful errors

    Code
      use_vignette()
    Condition
      Error in `use_vignette()`:
      ! `name` is absent but must be supplied.
    Code
      use_vignette("bad name")
    Condition
      Error:
      x "bad name" is not a valid filename for a vignette. It must:
      i Start with a letter.
      i Contain only letters, numbers, '_', and '-'.

