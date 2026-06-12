# Configure a project to work with AI coding agents

**\[experimental\]**

This function sets up a project to work with AI coding agents.
Specifically, it:

- Creates an `AGENTS.md` file containing project-specific instructions
  for R package development. This file is read by most coding agents,
  including Codex, Gemini CLI, and Cursor.

- Creates a `.claude/` directory to configure [Claude
  Code](https://code.claude.com), which doesn't yet read `AGENTS.md`:

  - `CLAUDE.md` imports `AGENTS.md`, so Claude Code uses the same
    instructions as other agents.

  - `settings.json` provides recommended permissions for R package
    development, including the ability to run R, format with
    [Air](https://posit-dev.github.io/air/), and run common development
    tools.

  - `skills/` contains various skills found useful by the tidyverse
    team. All skills have a `tidy-` prefix to avoid clashing with skills
    that you might provide. Skills use the [Agent
    Skills](https://agentskills.io) format, so they also work with other
    agents that read `.claude/skills/`.

  - `.gitignore` ignores `settings.local.json` (for user-specific
    settings).

- `.Rbuildignore` ignores `AGENTS.md` and `.claude/`, so they aren't
  included in your built package.

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
