# Set an environment variable in `.Renviron`

Adds or updates an environment variable in the user or project
`.Renviron` and immediately makes it available in the current session
via [`Sys.setenv()`](https://rdrr.io/r/base/Sys.setenv.html).

## Usage

``` r
use_env_var(name, value = NULL, scope = c("user", "project"))
```

## Arguments

- name:

  Name of the environment variable. Must contain only letters, digits,
  and underscores, and must start with a letter or underscore.

- value:

  Value to set. By default, you are prompted to enter the value securely
  using
  [`askpass::askpass()`](https://r-lib.r-universe.dev/askpass/reference/askpass.html).
  Otherwise, we **do not recommend** that you provide the value directly
  in code, as it may be visible in your command history. This argument
  exists primarily to allow you to set an environment variable to a
  value retrieved programmatically, e.g. from keyring.

- scope:

  Edit globally for the current **user** (`"user"`, the default), or
  locally for the current **project** (`"project"`). Setting a variable
  in the user scope ensures that it is available in all future R
  sessions.

## Value

Path to the `.Renviron` file, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
use_env_var("OPENAI_API_KEY")
} # }
```
