# use_vignette() gives useful errors

    Code
      use_vignette()
    Condition
      Error in `use_vignette()`:
      ! `name` is absent but must be supplied.
    Code
      use_vignette("bad name")
    Condition
      Error in `check_vignette_name()`:
      x "bad name" is not a valid filename for a vignette. It must:
      i Start with a letter.
      i Contain only letters, numbers, '_', and '-'.

# we error informatively for bad vignette extension

    Code
      check_vignette_extension("Rnw")
    Condition
      Error in `check_vignette_extension()`:
      x Unsupported file extension: "Rnw"
      i usethis can only create a vignette or article with one of these extensions: "Rmd" or "qmd".

