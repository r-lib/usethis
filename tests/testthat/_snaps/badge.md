# use_lifecycle_badge() handles bad and good input

    Code
      use_lifecycle_badge()
    Error <simpleError>
      argument "stage" is missing, with no default
    Code
      use_lifecycle_badge("eperimental")
    Error <rlang_error>
      `stage` must be one of "experimental", "stable", "superseded", or "deprecated".
      Did you mean "experimental"?

