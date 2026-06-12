#' Configure a project to work with AI coding agents
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function sets up a project to work with AI coding agents.
#' Specifically, it:
#'
#' - Creates an `AGENTS.md` file containing project-specific instructions for
#'   R package development. It includes general development advice, as well
#'   as pointers to specific skills provided by [learn_tidy_skill()].
#'
#'   This file is read by most coding agents, including Codex, Gemini CLI,
#'   and Cursor.
#'
#'   The file begins with a "This package" section for your own
#'   package-specific advice. If you re-run `use_tidy_agents()` to update
#'   `AGENTS.md`, the contents of this section are preserved.
#'
#' - Creates a `.claude/` directory to configure
#'   [Claude Code](https://code.claude.com), which doesn't yet read
#'   `AGENTS.md`:
#'
#'   - `CLAUDE.md` imports `AGENTS.md`, so Claude Code uses the same
#'     instructions as other agents.
#'
#'   - `.gitignore` ignores `settings.local.json` (for user-specific
#'     settings).
#'
#' - `.Rbuildignore` ignores `AGENTS.md` and `.claude/`, so they aren't
#'   included in your built package.
#' @export
#' @examples
#' \dontrun{
#' use_tidy_agents()
#' }
use_tidy_agents <- function() {
  agents_path <- proj_path("AGENTS.md")
  agents_lines <- read_utf8(path_package("usethis", "AGENTS.md"))
  if (file_exists(agents_path)) {
    agents_lines <- preserve_this_package(agents_lines, read_utf8(agents_path))
  }
  write_over(agents_path, agents_lines)
  use_build_ignore("AGENTS.md")

  use_directory(".claude", ignore = TRUE)
  copy_claude_directory()
  use_git_ignore("settings.local.json", directory = ".claude")

  invisible(TRUE)
}

#' Learn a specialized skill
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `learn_tidy_skill()` prints detailed instructions for performing a specialized
#' R package development task the way the tidyverse team does. It's primarily
#' designed to be called by AI coding agents: the `AGENTS.md` created by
#' [use_tidy_agents()] tells agents when to read each skill.
#'
#' @param name Name of the skill:
#'   * `"arg-checking"`: add input checking to a function.
#'   * `"deprecate"`: deprecate a function or argument.
#' @export
#' @examples
#' \dontrun{
#' learn_tidy_skill("deprecate")
#' }
learn_tidy_skill <- function(name) {
  skill_paths <- dir_ls(path_package("usethis", "skills"), glob = "*.md")
  skills <- path_ext_remove(path_file(skill_paths))
  name <- arg_match(name, values = skills)

  writeLines(read_utf8(path_package("usethis", "skills", paste0(name, ".md"))))
  invisible()
}

# Replace the "This package" section of `new` with the version found in
# `old`, so that user-supplied advice survives an update
preserve_this_package <- function(new, old) {
  new_section <- find_section(new, "## This package")
  old_section <- find_section(old, "## This package")
  if (is.null(new_section) || is.null(old_section)) {
    return(new)
  }

  c(
    new[seq2(1, new_section[1] - 1)],
    old[seq2(old_section[1], old_section[2])],
    new[seq2(new_section[2] + 1, length(new))]
  )
}

find_section <- function(lines, heading) {
  start <- which(lines == heading)
  if (length(start) != 1) {
    return(NULL)
  }

  headings <- grep("^## ", lines)
  end <- min(c(headings[headings > start], length(lines) + 1))
  c(start, end - 1)
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
