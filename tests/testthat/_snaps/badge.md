# use_lifecycle_badge() handles bad and good input

    Code
      use_lifecycle_badge("eperimental")
    Condition
      Error in `use_lifecycle_badge()`:
      ! `stage` must be one of "experimental", "stable", "superseded", or "deprecated", not "eperimental".
      i Did you mean "experimental"?

# use_r_universe_badge() needs to know the owner

    Code
      use_r_universe_badge()
    Condition
      Error in `use_r_universe_badge()`:
      x Can't determine the R-Universe owner of the {TESTPKG} package.
      ! No GitHub URL found in DESCRIPTION or the Git remotes.
      i Update the project configuration or provide an explicit `repo_spec`.

---

    Code
      use_r_universe_badge("OWNER_DIRECT/SCRUBBED")
    Message
      ! Can't find a README for the current project.
      i See `usethis::use_readme_rmd()` for help creating this file.
      i Badge link will only be printed to screen.
      [ ] Copy and paste the following lines into 'README':
        <!-- badges: start -->
        [![R-Universe version](https://OWNER_DIRECT.r-universe.dev/{TESTPKG}/badges/version)](https://OWNER_DIRECT.r-universe.dev/{TESTPKG})
        <!-- badges: end -->

---

    Code
      use_r_universe_badge()
    Message
      ! Can't find a README for the current project.
      i See `usethis::use_readme_rmd()` for help creating this file.
      i Badge link will only be printed to screen.
      [ ] Copy and paste the following lines into 'README':
        <!-- badges: start -->
        [![R-Universe version](https://OWNER_DESCRIPTION.r-universe.dev/{TESTPKG}/badges/version)](https://OWNER_DESCRIPTION.r-universe.dev/{TESTPKG})
        <!-- badges: end -->

---

    Code
      use_r_universe_badge()
    Message
      ! Can't find a README for the current project.
      i See `usethis::use_readme_rmd()` for help creating this file.
      i Badge link will only be printed to screen.
      [ ] Copy and paste the following lines into 'README':
        <!-- badges: start -->
        [![R-Universe version](https://OWNER_ORIGIN.r-universe.dev/{TESTPKG}/badges/version)](https://OWNER_ORIGIN.r-universe.dev/{TESTPKG})
        <!-- badges: end -->

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

