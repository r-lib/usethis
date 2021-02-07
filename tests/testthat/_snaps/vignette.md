# use_vignette() gives useful errors

    Code
      use_vignette()
    Error <simpleError>
      argument "name" is missing, with no default
    Code
      use_vignette("bad name")
    Error <usethis_error>
      'bad name' is not a valid filename for a vignette. It must:
      * Start with a letter.
      * Contain only letters, numbers, '_', and '-'.

