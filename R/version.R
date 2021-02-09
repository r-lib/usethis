#' Increment package version
#'
#' @description `use_version()` increments the "Version" field in `DESCRIPTION`,
#'   adds a new heading to `NEWS.md` (if it exists), and commits those changes
#'   (if package uses Git). It makes the same update to a line like `PKG_version
#'   = "x.y.z";` in `src/version.c` (if it exists).
#'
#' @description `use_dev_version()` increments to a development version, e.g.
#'   from 1.0.0 to 1.0.0.9000. If the existing version is already a development
#'   version with four components, it does nothing. Thin wrapper around
#'   `use_version()`.
#'
#' @param which A string specifying which level to increment, one of: "major",
#'   "minor", "patch", "dev". If `NULL`, user can choose interactively.
#'
#' @seealso The [version
#'   section](https://r-pkgs.org/description.html#version) of [R
#'   Packages](https://r-pkgs.org).
#'
#' @examples
#' \dontrun{
#' ## for interactive selection, do this:
#' use_version()
#'
#' ## request a specific type of increment
#' use_version("minor")
#' use_dev_version()
#' }
#'
#' @name use_version
NULL

#' @rdname use_version
#' @export
use_version <- function(which = NULL) {
  if (is.null(which) && !is_interactive()) {
    return(invisible(FALSE))
  }

  check_is_package("use_version()")
  challenge_uncommitted_changes(
    msg = "There are uncommitted changes and you're about to bump version"
  )

  new_ver <- choose_version("What should the new version be?", which)
  if (is.null(new_ver)) {
    return(invisible(FALSE))
  }

  use_description_field("Version", new_ver, overwrite = TRUE)
  if (names(new_ver) == "dev") {
    use_news_heading("(development version)")
  } else {
    use_news_heading(new_ver)
  }

  use_c_version(new_ver)

  git_ask_commit(
    "Increment version number",
    untracked = TRUE,
    paths = c("DESCRIPTION", "NEWS.md", path("src", "version.c"))
  )
  invisible(TRUE)
}

#' @rdname use_version
#' @export
use_dev_version <- function() {
  check_is_package("use_dev_version()")
  ver <- desc::desc_get_version(proj_get())
  if (length(unlist(ver)) > 3) {
    return(invisible())
  }
  use_version(which = "dev")
}

choose_version <- function(message, which = NULL) {
  ver <- desc::desc_get_version(proj_get())
  versions <- bump_version(ver)

  if (is.null(which)) {
    choice <- utils::menu(
      choices = glue(
        "{format(names(versions), justify = 'right')} --> {versions}"
      ),
      title = glue(
        "Current version is {ver}.\n",
        "{message} (0 to exit)"
      )
    )
    if (choice == 0) {
      return(invisible())
    } else {
      which <- names(versions)[choice]
    }
  }

  which <- match.arg(which, c("major", "minor", "patch", "dev"))
  versions[which]
}

bump_version <- function(ver) {
  bumps <- c("major", "minor", "patch", "dev")
  vapply(bumps, bump_, character(1), ver = ver)
}

bump_ <- function(x, ver) {
  d <- desc::desc(text = paste0("Version: ", ver))
  suppressMessages(d$bump_version(x)$get("Version")[[1]])
}

use_c_version <- function(ver) {
  version_path <- proj_path("src", "version.c")

  if (!file_exists(version_path)) {
    return()
  }

  hint <- glue("{project_name()}_version")
  ui_done("
    Setting {ui_field(hint)} to {ui_value(ver)} in {ui_path(version_path)}")

  lines <- read_utf8(version_path)

  re <- glue("(^.*{project_name()}_version = \")([0-9.]+)(\";$)")
  lines <- gsub(re, glue("\\1{ver}\\3"), lines)

  write_utf8(version_path, lines)
}
