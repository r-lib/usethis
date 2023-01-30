# can offer choices

    Code
      standalone_choose("tidyverse/forcats")
    Condition
      Error:
      ! No standalone files found in tidyverse/forcats.
    Code
      standalone_choose("r-lib/rlang")
    Condition
      Error:
      ! No standalone files found in r-lib/rlang.

# header provides useful summary

    Code
      standalone_header("r-lib/usethis", "R/standalone-test.R")
    Output
      [1] "# Standalone file: do not edit by hand"                                    
      [2] "# Source: <https://github.com/r-lib/usethis/blob/main/R/standalone-test.R>"
      [3] "# ----------------------------------------------------------------------"  
      [4] "#"                                                                         

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

