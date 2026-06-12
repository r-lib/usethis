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

# use_env_var() rejects values with newlines

    Code
      use_env_var("MY_KEY", value = "abc\ndef")
    Condition
      Error in `use_env_var()`:
      x `value` must not contain newline characters.
      i .Renviron does not support multi-line values.

---

    Code
      use_env_var("MY_KEY", value = "abc\rdef")
    Condition
      Error in `use_env_var()`:
      x `value` must not contain newline characters.
      i .Renviron does not support multi-line values.

# use_env_var() leaves file unchanged when overwrite is declined (non-interactive)

    Code
      use_env_var("MY_KEY", value = "new", scope = "user")
    Condition
      Error in `ui_yep()`:
      x User input required, but session is not interactive.
      i Query: "Overwrite the existing value for {.envvar {name}}?"
    Code
      use_env_var("MY_KEY", value = "new", scope = "user", overwrite = FALSE)
    Condition
      Error in `ui_yep()`:
      x User input required, but session is not interactive.
      i Query: "Overwrite the existing value for {.envvar {name}}?"

# use_env_var() rejects trailing-backslash value with surrounding whitespace

    Code
      use_env_var("MY_KEY", value = "  trailing\\")
    Condition
      Error in `renviron_quote()`:
      x `value` ends with a backslash and has surrounding whitespace, which cannot be encoded in '.Renviron'.
      i Remove the backslash or the surrounding whitespace.

# use_env_var() rejects values containing ${...}

    Code
      use_env_var("MY_KEY", value = "${HOME}")
    Condition
      Error in `renviron_quote()`:
      x `value` contains `${VAR}`, which '.Renviron' expands on re-read and cannot be stored literally.
      i Use a plain value without variable references.

---

    Code
      use_env_var("MY_KEY", value = "prefix_${VAR}_suffix")
    Condition
      Error in `renviron_quote()`:
      x `value` contains `${VAR}`, which '.Renviron' expands on re-read and cannot be stored literally.
      i Use a plain value without variable references.

