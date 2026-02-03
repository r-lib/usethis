# Configure a project to use Claude Code

**\[experimental\]**

This function sets up a project to use [Claude
Code](https://docs.anthropic.com/en/docs/claude-code). Specifically, it:

- Creates a `.claude/` directory with a `CLAUDE.md` file containing
  project-specific instructions for R package development.

- Creates a `.claude/settings.json` configuration file with recommended
  permissions for R package development, including the ability to run R,
  format with [Air](https://posit-dev.github.io/air/), and run common
  development tools.

- Creates a `.claude/skills/` directory containing various skills found
  useful by the tidyverse team. All skills have a `tidy-` prefix to
  avoid clashing with skills that you might provide.

- Updates `.claude/.gitignore` to ignore `settings.local.json` (for
  user-specific settings).

## Usage

``` r
use_claude_code()
```

## Examples

``` r
if (FALSE) { # \dontrun{
use_claude_code()
} # }
```
