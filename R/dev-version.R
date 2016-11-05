#' Increment development version
#'
#' This adds ".9000" to the package \code{DESCRIPTION}, adds a new heading to
#' \code{NEWS.md} (if it exists), and then checks the result into git.
#'
#' @export
use_dev_version <- function(base_path = ".") {
  if (uses_git(base_path) && git_uncommitted(base_path)) {
    stop(
      "Uncommited changes. Please commit to git before continuing",
      call. = FALSE
    )
  }

  desc_path <- file.path(base_path, "DESCRIPTION")

  ver <- package_version(desc::desc_get("Version", file = desc_path)[[1]])
  if (length(unlist(ver)) > 3) {
    stop("Already has development version", call. = FALSE)
  }

  message("* Adding .9000 to version")
  dev_ver <- paste0(version, ".9000")
  desc::desc_set("Version", dev_ver, file = desc_pat)

  news_path <- file.path(pkg$path, "news.md")
  if (file.exists(news_path)) {
    message("* Adding new heading to NEWS.md")

    news <- readLines(news_path)
    news <- c(
      paste0("# ", project_name(base_path), " ", dev_ver),
      "",
      news
    )
    writeLines(news, news_path)
  }

  if (uses_git(pkg$path)) {
    message("* Checking into git")
    r <- git2r::init(pkg$path)
    paths <- unlist(git2r::status(r))
    git2r::add(r, paths)
    git2r::commit(r, "Use development version")
  }

  invisible(TRUE)
}
