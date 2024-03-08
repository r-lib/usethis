# Legacy author fields are challenged

    Code
      challenge_legacy_author_fields()
    Message
      x Found legacy 'Author' and/or 'Maintainer' field in DESCRIPTION.
        usethis only supports modification of the 'Authors@R' field.
      i We recommend one of these paths forward:
      [ ] Delete the legacy fields and rebuild with `use_author()`; or
      [ ] Convert to 'Authors@R' with `desc::desc_coerce_authors_at_r()`, then delete
        the legacy fields.
    Condition
      Error:
      x User input required, but session is not interactive.
      i Query: "Do you want to cancel this operation and sort that out first?"

# Decline to tweak an existing author

    Code
      use_author("Jennifer", "Bryan", role = "cph")
    Condition
      Error in `use_author()`:
      x "Jennifer Bryan" already appears in 'Authors@R'.
        Please make the desired change directly in DESCRIPTION or call the desc package directly.

# Placeholder author is challenged

    Code
      use_author("Charlie", "Brown")
    Message
      v Adding to 'Authors@R' in DESCRIPTION:
        Charlie Brown [ctb]
      i 'Authors@R' appears to include a placeholder author:
        First Last <first.last@example.com> [aut, cre] (YOUR-ORCID-ID)

