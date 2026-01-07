#' Configure a project to use Claude Code
#'
#' @description
#' This function sets up a project to use
#' [Claude Code](https://docs.anthropic.com/en/docs/claude-code).
#' Specifically, it:
#'
#' - Creates a `.claude/` directory with a `CLAUDE.md` file containing
#'   project-specific instructions for R package development.
#'
#' - Creates a `.claude/settings.json` configuration file with recommended
#'   permissions for R package development, including the ability to run R,
#'   format with [Air](https://posit-dev.github.io/air/), and run common
#'   development tools.
#'
#' - Creates a `.claude/skills/` directory containing various skills found
#'   useful by the tidyverse team. All skills have a `tidy-` prefix to avoid
#'   clashing with skills that you might provide.
#'
#' - Updates `.claude/.gitignore` to ignore `settings.local.json` (for
#'   user-specific settings).
#'
#' @export
#' @examples
#' \dontrun{
#' use_claude_code()
#' }
use_claude_code <- function() {
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
    # ui_bullets(c("v" = "Creating {.path {pth(dest_file)}}."))
    # file_copy(source_file, dest_file, overwrite = TRUE)
  }
}
