# Configure a project to work with AI coding agents

**\[experimental\]**

This function sets up a project to work with AI coding agents.
Specifically, it:

- Creates an `AGENTS.md` file containing project-specific instructions
  for R package development. It includes general development advice, as
  well as pointers to specific skills provided by
  [`learn_tidy_skill()`](https://usethis.r-lib.org/dev/reference/learn_tidy_skill.md).

  This file is read by most coding agents, including Posit Assistant,
  Codex, Gemini CLI, and Cursor.

  The file begins with a "This package" section for your own
  package-specific advice. If you re-run `use_tidy_agents()` to update
  `AGENTS.md`, the contents of this section are preserved.

- `.Rbuildignore` ignores `AGENTS.md`, so it isn't included in your
  built package.

## Usage

``` r
use_tidy_agents()
```

## Examples

``` r
if (FALSE) { # \dontrun{
use_tidy_agents()
} # }
```
