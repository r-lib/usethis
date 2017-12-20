#' Use RStudio
#'
#' Creates an `.Rproj` file and adds RStudio files to `.gitignore`
#' and `.Rbuildignore`.
#'
#' @inheritParams use_template
#' @export
use_rstudio <- function() {
  use_template(
    "template.Rproj",
    paste0(project_name(), ".Rproj")
  )

  use_git_ignore(".Rproj.user")
  if (is_package()) {
    use_build_ignore(c("^.*\\.Rproj$", "^\\.Rproj\\.user$"), escape = FALSE)
  }

  invisible(TRUE)
}

#' Don't save/load user workspace between sessions
#'
#' R can save and reload the user's workspace between sessions via an `.RData`
#' file in the current directory. However, long-term reproducibility is enhanced
#' when you turn this feature off and reset R's memory at every restart. Fresh
#' starts provide timely feedback that encourages the development of scripts
#' that are complete and self-contained.
#'
#' Only `use_freshstarts("project")` is implemented so far, since RStudio
#' currently only supports modification of user-level or global options via the
#' user interface.
#'
#' @inheritParams edit
#'
#' @export
use_freshstarts <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)

  if (scope == "user") {
    message(
      "To make fresh starts the default in all RStudio sessions, \n",
      "you must set this interactively, for now.\n",
      "In Global Options, General:\n",
      "  * Uncheck \"Restore .RData into workspace at startup\"\n",
      "  * Set \"Save workspace to .RData on exit\" to \"Never\"\n",
      "\n",
      "`use_freshstarts(\"project\")` to always use fresh starts in this project."
    )
    return(invisible())
  }

  if (!is_rstudio_project()) {
    stop(project_name(), " is not an RStudio Project", call. = FALSE)
  }

  rproj_options <- build_rproj(
    rproj_path(),
    list(RestoreWorkspace = "No", SaveWorkspace = "No")
  )
  write_utf8(file.path(proj_get(), rproj_path()), rproj_options)
  restart_rstudio(
    "A restart of RStudio is required to activate fresh starts"
  )

  invisible()
}

# Is base_path an RStudio Project?
is_rstudio_project <- function(base_path = proj_get()) {
  res <- tryCatch(
    rprojroot::find_rstudio_root_file(path = base_path),
    error = function(e) NA
  )
  !is.na(res)
}

rproj_path <- function(base_path = proj_get()) {
  rproj_path <- dir(base_path, pattern = "\\.Rproj$")
  if (length(rproj_path) > 1) {
    stop("Multiple .Rproj files found", call. = FALSE)
  }
  if (length(rproj_path) == 1) rproj_path else NA_character_
}

# Is base_path open in RStudio?
in_rstudio <- function(base_path = proj_get()) {
  if (!rstudioapi::isAvailable())
    return(FALSE)

  if (!rstudioapi::hasFun("getActiveProject"))
    return(FALSE)

  proj <- rstudioapi::getActiveProject()

  normalizePath(proj) == normalizePath(base_path)
}

build_rproj <- function(file, fields) {
  lines <- readLines(file)
  file_fields <- lapply(lines, function(x) strsplit(x, split = ": ")[[1]])
  file_fields <- stats::setNames(
    lapply(file_fields, function(x) if (length(x) < 2) "" else x[[2]]),
    lapply(file_fields, function(x) if (length(x) < 1) "" else x[[1]])
  )
  file_fields <- utils::modifyList(file_fields, fields)
  is_blank <- names(file_fields) == ""
  ifelse(is_blank, "", paste0(names(file_fields), ": ", file_fields))
}
