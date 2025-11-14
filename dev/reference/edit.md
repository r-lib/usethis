# Open configuration files

- `edit_r_profile()` opens `.Rprofile`

- `edit_r_environ()` opens `.Renviron`

- `edit_r_makevars()` opens `.R/Makevars`

- `edit_git_config()` opens `.gitconfig` or `.git/config`

- `edit_git_ignore()` opens global (user-level) gitignore file and
  ensures its path is declared in your global Git config.

- `edit_pkgdown_config` opens the pkgdown YAML configuration file for
  the current Project.

- `edit_rstudio_snippets()` opens RStudio's snippet config for the given
  type.

- `edit_rstudio_prefs()` opens [RStudio's preference
  file](https://usethis.r-lib.org/dev/reference/use_rstudio_preferences.md).

## Usage

``` r
edit_r_profile(scope = c("user", "project"))

edit_r_environ(scope = c("user", "project"))

edit_r_buildignore()

edit_r_makevars(scope = c("user", "project"))

edit_rstudio_snippets(
  type = c("r", "markdown", "c_cpp", "css", "html", "java", "javascript", "python",
    "sql", "stan", "tex", "yaml")
)

edit_rstudio_prefs()

edit_git_config(scope = c("user", "project"))

edit_git_ignore(scope = c("user", "project"))

edit_pkgdown_config()
```

## Arguments

- scope:

  Edit globally for the current **user**, or locally for the current
  **project**

- type:

  Snippet type (case insensitive text).

## Value

Path to the file, invisibly.

## Details

The `edit_r_*()` functions consult R's notion of user's home directory.
The `edit_git_*()` functions (and usethis in general) inherit home
directory behaviour from the fs package, which differs from R itself on
Windows. The fs default is more conventional in terms of the location of
user-level Git config files. See
[`fs::path_home()`](https://fs.r-lib.org/reference/path_expand.html) for
more details.

Files created by `edit_rstudio_snippets()` will *mask*, not supplement,
the built-in default snippets. If you like the built-in snippets, copy
them and include with your custom snippets.
