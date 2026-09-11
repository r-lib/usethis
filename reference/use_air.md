# Configure a project to use Air

[Air](https://posit-dev.github.io/air/) is an extremely fast R code
formatter. This function sets up a project to use Air. Specifically, it:

- Creates an empty `air.toml` configuration file. If either an
  `air.toml` or `.air.toml` file already existed, nothing is changed. If
  the project is an R package, `.Rbuildignore` is updated to ignore this
  file.

- Creates a `.vscode/` directory and adds recommended settings to
  `.vscode/settings.json` and `.vscode/extensions.json`. These settings
  are used by the Air extension installed through either VS Code or
  Positron, see the Installation section for more details. Specifically
  it:

  - Sets `editor.formatOnSave = true` for R and Quarto files to enable
    formatting on every save.

  - Sets `editor.defaultFormatter` to Air for R files to ensure that Air
    is always selected as the formatter for this project. Likewise, sets
    the default formatter for Quarto.

  - Sets the Air extension as a "recommended" extension for this
    project, which triggers a notification for contributors coming to
    this project that don't yet have the Air extension installed.

  If the project is an R package, `.Rbuildignore` is updated to ignore
  the `.vscode/` directory.

  If you'd like to opt out of VS Code / Positron specific setup, set
  `vscode = FALSE`, but remember that even if you work in RStudio, other
  contributors may prefer another editor.

Note that "using Air" breaks down into a few steps, and `use_air()` does
*one* of them. Here's an overview:

- Installation: Air might already be included in your IDE (e.g.
  Positron) or can be added as an external formatter (e.g. RStudio) or
  as an extension (e.g. VS Code). Read the guide that applies to your
  situation:

  - [Air in an editor](https://posit-dev.github.io/air/editors.html)

  - [Air at the command line](https://posit-dev.github.io/air/cli.html)

- Configuration: `use_air()` does this!

- Invocation: There are many ways to run Air. In an IDE, you can expect
  support for moves like "format on save", "format selection", and so
  on. At the command line, you can format individual files or entire
  directories.

- Continuous integration: Two workflows are available for running Air
  via GitHub Actions: `format-suggest` or `format-check`. Learn more in
  [Air's documentation of its GHA
  integrations](https://posit-dev.github.io/air/integration-github-actions.html).
  You can set up either workflow in your project like so:

      use_github_action(url = "https://github.com/posit-dev/setup-air/blob/main/examples/format-suggest.yaml")
      use_github_action(url = "https://github.com/posit-dev/setup-air/blob/main/examples/format-check.yaml")

## Usage

``` r
use_air(vscode = TRUE)
```

## Arguments

- vscode:

  Either:

  - `TRUE` to set up VS Code and Positron specific Air settings. This is
    the default.

  - `FALSE` to opt out of those settings.

## Examples

``` r
if (FALSE) { # \dontrun{
# Prepare an R package or project to use Air
use_air()
} # }
```
