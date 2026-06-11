#' Configure a project to work with AI coding agents
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function sets up a project to work with AI coding agents.
#' Specifically, it:
#'
#' - Creates an `AGENTS.md` file containing project-specific instructions for
#'   R package development. This file is read by most coding agents, including
#'   Codex, Gemini CLI, and Cursor.
#'
#' - Creates a `.claude/` directory to configure
#'   [Claude Code](https://code.claude.com), which doesn't yet read
#'   `AGENTS.md`:
#'
#'   - `CLAUDE.md` imports `AGENTS.md`, so Claude Code uses the same
#'     instructions as other agents.
#'
#'   - `settings.json` provides recommended permissions for R package
#'     development, including the ability to run R, format with
#'     [Air](https://posit-dev.github.io/air/), and run common development
#'     tools.
#'
#'   - `skills/` contains various skills found useful by the tidyverse team.
#'     All skills have a `tidy-` prefix to avoid clashing with skills that you
#'     might provide. Skills use the [Agent Skills](https://agentskills.io)
#'     format, so they also work with other agents that read
#'     `.claude/skills/`.
#'
#'   - `.gitignore` ignores `settings.local.json` (for user-specific
#'     settings).
#'
#' @export
#' @examples
#' \dontrun{
#' use_tidy_agents()
#' }
use_tidy_agents <- function() {
  write_over(
    proj_path("AGENTS.md"),
    read_utf8(path_package("usethis", "AGENTS.md"))
  )
  use_build_ignore("AGENTS.md")

  use_directory(".claude", ignore = TRUE)
  copy_claude_directory()
  use_git_ignore("settings.local.json", directory = ".claude")

  invisible(TRUE)
}

copy_claude_directory <- function() {
  source_dir <- path_package("usethis", "claude")
  dest_dir <- proj_path(".claude")

  source_dirs <- dir_ls(source_dir, recurse = TRUE, type = "directory")
  dir_create(path(dest_dir, path_rel(source_dirs, source_dir)))

  source_files <- dir_ls(source_dir, recurse = TRUE, type = "file")
  for (source_file in source_files) {
    rel_path <- path_rel(source_file, source_dir)
    dest_file <- path(dest_dir, rel_path)

    write_over(dest_file, readLines(source_file), overwrite = TRUE)
  }
}
