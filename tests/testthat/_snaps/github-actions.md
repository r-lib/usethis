# use_github_action() allows for custom urls

    Code
      use_github_action(url = "https://raw.githubusercontent.com/r-lib/actions/v1/examples/check-full.yaml",
        readme = "https://github.com/r-lib/actions/blob/v1/examples/README.md")
    Message <message>
      v Creating '.github/'
      v Adding '^\\.github$' to '.Rbuildignore'
      v Adding '*.html' to '.github/.gitignore'
      v Creating '.github/workflows/'
      v Saving 'r-lib/actions/examples/check-full.yaml@v1' to '.github/workflows/check-full.yaml'
      * Learn more at <https://github.com/r-lib/actions/blob/v1/examples/README.md>.

# check_uses_github_actions() can throw error

    Code
      check_uses_github_actions()
    Error <usethis_error>
      Cannot detect that package '{TESTPKG}' already uses GitHub Actions.
      Do you need to run `use_github_actions()`?

