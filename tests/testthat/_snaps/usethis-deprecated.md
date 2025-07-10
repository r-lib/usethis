# use_tidy_eval() is deprecated

    Code
      use_tidy_eval()
    Condition
      Error:
      ! `use_tidy_eval()` was deprecated in usethis 2.2.0 and is now defunct.
      i There is no longer a need to systematically import and/or re-export functions
      i Instead import functions as needed, with e.g.:
      i usethis::use_import_from("rlang", c(".data", ".env"))

# use_tidy_style() is deprecated

    Code
      use_tidy_style()
    Condition
      Warning:
      `use_tidy_style()` was deprecated in usethis 3.2.0.
      i Please use `use_air()` instead.
      i To continue using the styler package, call `styler::style_pkg()` or `styler::style_dir()` directly.

