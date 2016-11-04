#' Increment development version
#'
#' This adds ".9000" to the package \code{DESCRIPTION}, adds a new heading to
#' \code{NEWS.md} (if it exists), and then checks the result into git.
#'
#' @export
use_dev_version <- function(pkg = ".") {
  pkg <- as.package(pkg)

  if (uses_git(pkg$path) && git_uncommitted(pkg$path)) {
    stop(
      "Uncommited changes. Please commit to git before continuing",
      call. = FALSE
    )
  }

  message("* Adding .9000 to version")
  desc_path <- file.path(pkg$path, "DESCRIPTION")
  DESCRIPTION <- read_dcf(desc_path)
  if (length(unlist(package_version(DESCRIPTION$Version))) > 3) {
    stop("Already has development version", call. = FALSE)
  }
  DESCRIPTION$Version <- paste0(DESCRIPTION$Version, ".9000")
  write_dcf(desc_path, DESCRIPTION)

  news_path <- file.path(pkg$path, "news.md")
  if (file.exists(news_path)) {
    message("* Adding new heading to NEWS.md")

    news <- readLines(news_path)
    news <- c(
      paste0("# ", pkg$package, " ", DESCRIPTION$Version),
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
