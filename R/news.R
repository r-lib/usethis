#' Create a simple `NEWS.md`
#'
#' This creates a basic `NEWS.md` in the root directory.
#'
#' @inheritParams use_template
#' @seealso The [important files
#'   section](https://r-pkgs.org/release.html#important-files) of [R
#'   Packages](https://r-pkgs.org).
#' @export
use_news_md <- function(open = rlang::is_interactive()) {
  use_template(
    "NEWS.md",
    data = package_data(),
    open = open
  )

  git_ask_commit("Add NEWS.md", untracked = TRUE, paths = "NEWS.md")
}

use_news_heading <- function(version) {
  news_path <- proj_path("NEWS.md")
  if (!file_exists(news_path)) {
    return(invisible())
  }

  news <- read_utf8(news_path)
  title <- glue("# {project_name()} {version}")

  if (title == news[[1]]) {
    return(invisible())
  }

  development_title <- glue("# {project_name()} (development version)")
  if (development_title == news[[1]]) {
    news[[1]] <- title

    ui_done("Replacing development heading in NEWS.md")
    return(write_utf8(news_path, news))
  }

  ui_done("Adding new heading to NEWS.md")
  write_utf8(news_path, c(title, "", news))
}
