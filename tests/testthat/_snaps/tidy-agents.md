# learn_tidy_skill() errors informatively without a skill

    Code
      learn_tidy_skill()
    Condition
      Error in `learn_tidy_skill()`:
      ! `name` is required.
      i Available skills: "arg-checking", "deprecate", and "package-setup".

# learn_tidy_skill() errors informatively for unknown skill

    Code
      learn_tidy_skill("doesnt-exist")
    Condition
      Error in `learn_tidy_skill()`:
      ! `name` must be one of "arg-checking", "deprecate", or "package-setup", not "doesnt-exist".

