#' Increment version number
#'
#' This increments the "Version" field in `DESCRIPTION`, adds a new heading
#' to `NEWS.md` (if it exists), and then checks the result into git.
#'
#' @param level Which level to increment, must be one of "Mayor", "Minor",
#' "Patch" or "Development". Defaults to NULL which activates interactive
#' control.
#' @param increment Numerical. How much to increment the level by.
#' Defaults to 1.
#'
#' @export
use_version <- function(level = NULL, increment = 1) {
  check_is_package("use_version()")
  if (uses_git() && git_uncommitted()) {
    stop(
      "Uncommited changes. Please commit to git before continuing",
      call. = FALSE
    )
  }

  types <- c("Mayor", "Minor", "Patch", "Development")

  ver <- desc::desc_get_version(proj_get())

  if(is.null(level)) {
    choice1 <- utils::menu(choices = types,
                           title = paste0("Current version is ", paste0(ver),
                                          " what will you increment?"))


    increment_types <- c("1", "10", "custom")
    choice2 <- utils::menu(choices = increment_types,
                           title = paste0("How much will you increase by?"))

    if(choice2 == 3) {
      increment <- as.numeric(readline(prompt = "Enter custom increment: "))
    } else if(choice2 == 2) {
      increment <- 10
    } else {
      increment <- 1
    }
  } else {
    choice1 <- pmatch(level, types)
  }

  ver[[1, choice1]] <- ver[[1, choice1]] + increment

  if(choice1 == 1) {
    ver[[1, 2]] <- 0
  }
  if(choice1 < 3) {
    ver[[1, 3]] <- 0
  }

  use_description_field("Version", paste0(ver), overwrite = TRUE)
  use_news_heading(paste0(ver))
  git_check_in(
    base_path = proj_get(),
    paths = c("DESCRIPTION", "NEWS.md"),
    message = "Incrementing version number"
  )

  invisible(TRUE)
}
