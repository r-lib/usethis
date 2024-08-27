#' Create a simple `NEWS.md`
#'
#' This creates a basic `NEWS.md` in the root directory.
#'
#' @inheritParams use_template
#' @seealso The [other markdown files
#'   section](https://r-pkgs.org/other-markdown.html) of [R
#'   Packages](https://r-pkgs.org).
#' @export
use_news_md <- function(open = rlang::is_interactive()) {
  check_is_package("use_news_md()")

  version <- if (is_dev_version()) "(development version)" else proj_version()

  on_cran <- !is.null(cran_version())

  if (on_cran) {
    init_bullet <- "Added a `NEWS.md` file to track changes to the package."
  } else {
    init_bullet <- "Initial CRAN submission."
  }

  use_template(
    "NEWS.md",
    data = list(
      Package = project_name(),
      Version = version,
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
  idx <- match(TRUE, grepl("[^[:space:]]", news))

  if (is.na(idx)) {
    return(news)
  }

  title <- glue("# {project_name()} {version}")
  if (title == news[[idx]]) {
    return(invisible())
  }

  development_title <- glue("# {project_name()} (development version)")
  if (development_title == news[[idx]]) {
    news[[idx]] <- title

    ui_bullets(c("v" = "Replacing development heading in {.path NEWS.md}."))
    return(write_utf8(news_path, news))
  }

  ui_bullets(c("v" = "Adding new heading to {.path NEWS.md}."))
  write_utf8(news_path, c(title, "", news))
}
