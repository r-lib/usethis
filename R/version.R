#' Increment package version
#'
#' Increments the "Version" field in `DESCRIPTION`, adds a new heading to
#' `NEWS.md` (if it exists), and commits those changes (if package uses Git).
#'
#' @param which A string specifying which level to increment, one of: "major",
#'   "minor", "patch", "dev". If `NULL`, user can choose interactively.
#'
#' @export
use_version <- function(which = NULL) {
  check_is_package("use_version()")
  if (uses_git() && git_uncommitted()) {
    stop(
      "Uncommited changes. Please commit to git before continuing",
      call. = FALSE
    )
  }

  ver <- desc::desc_get_version(proj_get())

  if(is.null(which) && !interactive()) {
    return(invisible(ver))
  }

  versions <- bump_version(ver)

  if (is.null(which)) {
    choice <- utils::menu(
      choices = paste0(names(versions), " --> ", versions),
      title = paste0(
        "Current version is ", ver, "\n", "Which part to increment?"
      )
    )
    which <- names(versions)[choice]
  }
  which <- match.arg(which, c("major", "minor", "patch", "dev"))
  new_ver <- versions[which]

  use_description_field("Version", new_ver, overwrite = TRUE)
  use_news_heading(new_ver)
  git_check_in(
    base_path = proj_get(),
    paths = c("DESCRIPTION", "NEWS.md"),
    message = "Incrementing version number"
  )
  invisible(TRUE)
}

bump_version <- function(ver) {
  bumps <- c("major", "minor", "patch", "dev")
  vapply(bumps, bump_, character(1), ver = ver)
}

bump_ <- function(x, ver) {
  d <- desc::desc(text = paste0("Version: ", ver))
  suppressMessages(d$bump_version(x)$get("Version")[[1]])
}
