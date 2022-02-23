# use_github_action() allows for custom urls

    Code
      use_github_action(url = "https://raw.githubusercontent.com/r-lib/actions/v2/examples/check-full.yaml",
        readme = "https://github.com/r-lib/actions/blob/v2/examples/README.md")
    Message <rlang_message>
      v Creating '.github/'
      v Adding '^\\.github$' to '.Rbuildignore'
      v Adding '*.html' to '.github/.gitignore'
      v Creating '.github/workflows/'
      v Saving 'r-lib/actions/examples/check-full.yaml@v2' to '.github/workflows/check-full.yaml'
      * Learn more at <https://github.com/r-lib/actions/blob/v2/examples/README.md>.

# use_github_action() accepts a ref

    Code
      read_utf8(proj_path(".github/workflows/check-full.yaml"), n = 1)
    Output
      [1] "# Workflow derived from https://github.com/r-lib/actions/tree/master/examples"

# check_uses_github_actions() can throw error

    Code
      check_uses_github_actions()
    Error <usethis_error>
      Cannot detect that package '{TESTPKG}' already uses GitHub Actions.
      Do you need to run `use_github_actions()`?

