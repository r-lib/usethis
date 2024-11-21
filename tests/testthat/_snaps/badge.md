# use_lifecycle_badge() handles bad and good input

    Code
      use_lifecycle_badge("eperimental")
    Condition
      Error in `use_lifecycle_badge()`:
      ! `stage` must be one of "experimental", "stable", "superseded", or "deprecated", not "eperimental".
      i Did you mean "experimental"?

# use_r_universe_badge() needs a repository

    Code
      use_r_universe_badge()
    Condition
      Error in `use_r_universe_badge()`:
      x {TESTPKG} must have a repo URL in DESCRITPION to create a badge.
      i Use `usethis::use_badge()` if you have a different configuration.
      i If {TESTPKG} is on CRAN, you can also see <https://cran.dev/{TESTPKG}> for a redirect to the r-universe homepage.

# use_posit_cloud_badge() handles bad and good input

    Code
      use_posit_cloud_badge()
    Condition
      Error in `use_posit_cloud_badge()`:
      ! `url` must be a valid name, not absent.

---

    Code
      use_posit_cloud_badge(123)
    Condition
      Error in `use_posit_cloud_badge()`:
      ! `url` must be a valid name, not the number 123.

---

    Code
      use_posit_cloud_badge("http://posit.cloud/123")
    Condition
      Error in `use_posit_cloud_badge()`:
      x `usethis::use_posit_cloud_badge()` requires a link to an existing Posit Cloud project of the form "https://posit.cloud/content/<project-id>" or "https://posit.cloud/spaces/<space-id>/content/<project-id>".

