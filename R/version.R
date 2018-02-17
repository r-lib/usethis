#' Increment version number
#'
#' This increments the "Version" field in `DESCRIPTION`, adds a new heading
#' to `NEWS.md` (if it exists), and then checks the result into git.
#'
#' @param which Which level to increment, must be one of "dev", "patch",
#' "minor" or "major". Defaults to NULL which activates interactive
#' control.
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

  types <- c("major", "minor", "patch", "dev")

  ver <- desc::desc_get_version(proj_get())

  vers <- c(bump_version(ver, 1),
            bump_version(ver, 2),
            bump_version(ver, 3),
            bump_version(ver, 4))

  if(is.null(which)) {
    choice <- utils::menu(choices = paste0(types, " --> ", vers),
                           title = paste0("Current version is ", paste0(ver),
                                          "\nwhat part to increment?"))
    which <- types[which]
  } else {
    choice <- pmatch(which, types)
  }

  new_ver <- vers[choice]

  use_description_field("Version", paste0(new_ver), overwrite = TRUE)
  use_news_heading(paste0(new_ver))
  git_check_in(
     base_path = proj_get(),
     paths = c("DESCRIPTION", "NEWS.md"),
     message = "Incrementing version number"
   )
   invisible(TRUE)
}
