# use_tidy_dependencies() isn't overly informative

    Code
      use_tidy_dependencies()
    Message
      v Adding 'rlang' to Imports field in DESCRIPTION
      v Adding 'lifecycle' to Imports field in DESCRIPTION
      v Adding 'cli' to Imports field in DESCRIPTION
      v Adding 'glue' to Imports field in DESCRIPTION
      v Adding 'withr' to Imports field in DESCRIPTION
      v Adding '@import rlang' to 'R/tidydeps-package.R'
      v Adding '@importFrom glue glue' to 'R/tidydeps-package.R'
      v Adding '@importFrom lifecycle deprecated' to 'R/tidydeps-package.R'
      v Writing 'NAMESPACE'
      v Saving 'r-lib/rlang/R/compat-purrr.R' to 'R/compat-purrr.R'

# use_tidy_eval() is defunct

    Code
      use_tidy_eval()
    Condition
      Error:
      ! `use_tidy_eval()` was deprecated in usethis 2.2.0 and is now defunct.
      i There is no longer a need to systemically import and/or re-export functions
      i Instead import functions as needed using the following code:
      i usethis::use_import_from("rlang", c(".data", ".env"))
      i usethis::use_import_from("rlang", ":=")

