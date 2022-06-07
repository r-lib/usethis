# use_lifecycle_badge() handles bad and good input

    Code
      use_lifecycle_badge()
    Condition
      Error in `tolower()`:
      ! argument "stage" is missing, with no default
    Code
      use_lifecycle_badge("eperimental")
    Condition
      Error in `use_lifecycle_badge()`:
      ! `stage` must be one of "experimental", "stable", "superseded", or "deprecated", not "eperimental".
      i Did you mean "experimental"?

