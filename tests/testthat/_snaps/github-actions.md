# use_github_action() allows for custom urls

    Code
      use_github_action(url = "https://raw.githubusercontent.com/r-lib/actions/v2/examples/check-full.yaml",
        readme = "https://github.com/r-lib/actions/blob/v2/examples/README.md")
    Message
      v Creating '.github/'.
      v Adding "^\\.github$" to '.Rbuildignore'.
      v Adding "*.html" to '.github/.gitignore'.
      v Creating '.github/workflows/'.
      v Saving "r-lib/actions/examples/check-full.yaml@v2" to
        '.github/workflows/R-CMD-check.yaml'.
      [ ] Learn more at
        <https://github.com/r-lib/actions/blob/v2/examples/README.md>.
      v Adding "R-CMD-check badge" to 'README.md'.

# use_github_action() still errors in non-interactive environment

    Code
      use_github_action()
    Condition
      Error in `use_github_action()`:
      ! `name` is absent and must be supplied

# use_github_action() accepts a ref

    Code
      read_utf8(proj_path(".github/workflows/R-CMD-check.yaml"), n = 1)
    Output
      [1] "# Workflow derived from https://github.com/r-lib/actions/tree/master/examples"

# check_uses_github_actions() can throw error

    Code
      check_uses_github_actions()
    Condition
      Error in `check_uses_github_actions()`:
      x Cannot detect that package {TESTPKG} already uses GitHub Actions.
      i Do you need to run `use_github_action()`?

