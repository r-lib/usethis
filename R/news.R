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
  check_is_package()

  ver <- proj_version()
  on_cran <- !is.null(cran_version())
  version_string <- if (is_dev_version(ver)) "(development version)" else ver

  if (!on_cran && package_version(ver) <= package_version("0.1.0")) {
    init_bullet <- "Initial submission."
  } else {
    init_bullet <- "Added a `NEWS.md` file to track changes to the package."
  }

  use_template(
    "NEWS.md",
    data = list(
      Package = project_name(),
      Version = version_string,
      InitialBullet = init_bullet
    ),
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
