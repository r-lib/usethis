# use_lifecycle_badge() handles bad and good input

    Code
      use_lifecycle_badge("eperimental")
    Condition
      Error in `use_lifecycle_badge()`:
      ! `stage` must be one of "experimental", "stable", "superseded", or "deprecated", not "eperimental".
      i Did you mean "experimental"?

# use_rscloud_badge() handles bad and good input

    Code
      use_posit_cloud_badge()
    Condition
      Error in `is.factor()`:
      ! argument "url" is missing, with no default

---

    Code
      use_posit_cloud_badge(123)
    Condition
      Error:
      ! `usethis::use_posit_cloud_badge()` requires a link to an existing Posit Cloud project of the form 'https://posit.cloud/content/<project-id>' or 'https://posit.cloud/spaces/<space-id>/content/<project-id>'.

---

    Code
      use_posit_cloud_badge("http://posit.cloud/123")
    Condition
      Error:
      ! `usethis::use_posit_cloud_badge()` requires a link to an existing Posit Cloud project of the form 'https://posit.cloud/content/<project-id>' or 'https://posit.cloud/spaces/<space-id>/content/<project-id>'.

---

    Code
      use_rscloud_badge("https://rstudio.cloud/content/123")
    Condition
      Error:
      ! `usethis::use_posit_cloud_badge()` requires a link to an existing Posit Cloud project of the form 'https://posit.cloud/content/<project-id>' or 'https://posit.cloud/spaces/<space-id>/content/<project-id>'.

---

    Code
      use_rscloud_badge("https://posit.cloud/project/123")
    Condition
      Error:
      ! `usethis::use_posit_cloud_badge()` requires a link to an existing Posit Cloud project of the form 'https://posit.cloud/content/<project-id>' or 'https://posit.cloud/spaces/<space-id>/content/<project-id>'.

