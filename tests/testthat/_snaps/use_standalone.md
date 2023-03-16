# can offer choices

    Code
      standalone_choose("tidyverse/forcats", ref = "v1.0.0")
    Condition
      Error:
      ! No standalone files found in tidyverse/forcats.
    Code
      standalone_choose("r-lib/rlang", ref = "4670cb233ecc8d11")
    Condition
      Error:
      ! `file` is absent, but must be supplied.
      i Possible options are cli, downstream-deps, lazyeval, lifecycle, linked-version, obj-type, purrr, rlang, s3-register, sizes, types-check, vctrs, or zeallot.

# header provides useful summary

    Code
      standalone_header("r-lib/usethis", "R/standalone-test.R")
    Output
      [1] "# Standalone file: do not edit by hand"                                    
      [2] "# Source: <https://github.com/r-lib/usethis/blob/main/R/standalone-test.R>"
      [3] "# ----------------------------------------------------------------------"  
      [4] "#"                                                                         

# can extract imports

    Code
      extract_imports("# imports: rlang (== 1.0.0)")
    Condition
      Error in `extract_imports()`:
      ! Version specification must use `>=`.
    Code
      extract_imports("# imports: rlang (>= 1.0.0), purrr")
    Condition
      Error in `extract_imports()`:
      ! Version field can't contain comma.
      i Do you need to wrap in a list?
    Code
      extract_imports("# imports: foo (>=0.0.0)")
    Condition
      Error in `extract_imports()`:
      ! Can't parse version `foo (>=0.0.0)` in `imports:` field.
      i Example of expected version format: `rlang (>= 1.0.0)`.

# errors on malformed dependencies

    Code
      standalone_dependencies(c(), "test.R")
    Condition
      Error:
      ! Can't find yaml metadata in 'test.R'.
    Code
      standalone_dependencies(c("# ---", "# dependencies: 1", "# ---"), "test.R")
    Condition
      Error:
      ! Invalid dependencies specification in 'test.R'.

