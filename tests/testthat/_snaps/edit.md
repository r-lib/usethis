# can edit snippets

    Code
      edit_rstudio_snippets("not-existing-type")
    Condition
      Error in `match.arg()`:
      ! 'arg' should be one of "r", "markdown", "c_cpp", "css", "html", "java", "javascript", "python", "sql", "stan", "tex", "yaml"

# use_env_var() rejects invalid env var names

    Code
      use_env_var("bad name")
    Condition
      Error in `use_env_var()`:
      x `name` must be a valid environment variable name.
      x "bad name" contains invalid characters.
      i Valid names start with a letter or underscore and contain only letters, digits, and underscores.

---

    Code
      use_env_var("123bad")
    Condition
      Error in `use_env_var()`:
      x `name` must be a valid environment variable name.
      x "123bad" contains invalid characters.
      i Valid names start with a letter or underscore and contain only letters, digits, and underscores.

---

    Code
      use_env_var("bad-name")
    Condition
      Error in `use_env_var()`:
      x `name` must be a valid environment variable name.
      x "bad-name" contains invalid characters.
      i Valid names start with a letter or underscore and contain only letters, digits, and underscores.

