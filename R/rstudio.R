#' Add RStudio Project infrastructure
#'
#' It is likely that you want to use [create_project()] or [create_package()]
#' instead of `use_rstudio()`! Both `create_*()` functions can add RStudio
#' Project infrastructure to a pre-existing project or package. `use_rstudio()`
#' is mostly for internal use or for those creating a usethis-like package for
#' their organization. It does the following in the current project, often after
#' executing `proj_set(..., force = TRUE)`:
#'   * Creates an `.Rproj` file
#'   * Adds RStudio files to `.gitignore`
#'   * Adds RStudio files to `.Rbuildignore`, if project is a package
#'
#' @param line_ending Line ending
#' @export
use_rstudio <- function(line_ending = c("posix", "windows")) {
  line_ending <- arg_match(line_ending)
  line_ending <- c("posix" = "Posix", "windows" = "Windows")[[line_ending]]

  rproj_file <- paste0(project_name(), ".Rproj")
  new <- use_template("template.Rproj", rproj_file,
    data = list(line_ending = line_ending)
  )

  use_git_ignore(".Rproj.user")
  if (is_package()) {
    use_build_ignore(c(rproj_file, ".Rproj.user"))
  }

  invisible(new)
}

#' Don't save/load user workspace between sessions
#'
#' R can save and reload the user's workspace between sessions via an `.RData`
#' file in the current directory. However, long-term reproducibility is enhanced
#' when you turn this feature off and clear R's memory at every restart.
#' Starting with a blank slate provides timely feedback that encourages the
#' development of scripts that are complete and self-contained. More detail can
#' be found in the blog post [Project-oriented
#' workflow](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/).
#'
#' Only `use_blank_slate("project")` is automated so far, since RStudio
#' currently only supports modification of user-level or global options via the
#' user interface.
#'
#' @inheritParams edit
#'
#' @export
use_blank_slate <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)

  if (scope == "user") { # nocov start
    ui_todo(
      "To start ALL RStudio sessions with a blank slate, \\
      you must set this interactively, for now."
    )
    ui_todo(
      "In {ui_field('Global Options > General')}, \\
      do NOT check {ui_field('Restore .RData into workspace at startup')}."
    )
    ui_todo(
      "In {ui_field('Global Options > General')}, \\
      set {ui_field('Save workspace to .RData on exit')} to {ui_value('Never')}."
    )
    ui_todo(
      "Call {ui_code('use_blank_slate(\"project\")')} to opt in to the \\
      blank slate workflow for a specific project."
    )
    return(invisible())
  } # nocov end

  if (!is_rstudio_project()) {
    ui_stop("{ui_value(project_name())} is not an RStudio Project.")
  }

  rproj_fields <- modify_rproj(
    rproj_path(),
    list(RestoreWorkspace = "No", SaveWorkspace = "No")
  )
  write_utf8(rproj_path(), serialize_rproj(rproj_fields))
  restart_rstudio("Restart RStudio with a blank slate?")

  invisible()
}

# Is base_path an RStudio Project or inside an RStudio Project?
is_rstudio_project <- function(base_path = proj_get()) {
  res <- tryCatch(
    rprojroot::find_rstudio_root_file(path = base_path),
    error = function(e) NA
  )
  !is.na(res)
}

rproj_path <- function(base_path = proj_get()) {
  rproj_path <- dir_ls(base_path, regexp = "[.]Rproj$")
  if (length(rproj_path) > 1) {
    ui_stop("Multiple .Rproj files found.")
  }
  if (length(rproj_path) == 1) rproj_path else NA_character_
}

# Is base_path open in RStudio?
in_rstudio <- function(base_path = proj_get()) {
  if (!rstudioapi::isAvailable()) {
    return(FALSE)
  }

  if (!rstudioapi::hasFun("getActiveProject")) {
    return(FALSE)
  }

  proj <- rstudioapi::getActiveProject()

  if (is.null(proj)) {
    return(FALSE)
  }

  path_real(proj) == path_real(base_path)
}

in_rstudio_server <- function() {
  if (!rstudioapi::isAvailable()) {
    return(FALSE)
  }
  identical(rstudioapi::versionInfo()$mode, "server")
}

parse_rproj <- function(file) {
  lines <- as.list(read_utf8(file))
  has_colon <- grepl(":", lines)
  fields <- lapply(lines[has_colon], function(x) strsplit(x, split = ": ")[[1]])
  lines[has_colon] <- vapply(fields, `[[`, "character", 2)
  names(lines)[has_colon] <- vapply(fields, `[[`, "character", 1)
  names(lines)[!has_colon] <- ""
  lines
}

modify_rproj <- function(file, update) {
  utils::modifyList(parse_rproj(file), update)
}

serialize_rproj <- function(fields) {
  named <- nzchar(names(fields))
  as.character(ifelse(named, paste0(names(fields), ": ", fields), fields))
}

# Must be last command run
restart_rstudio <- function(message = NULL) {
  if (!in_rstudio(proj_get())) {
    return(FALSE)
  }

  if (!is_interactive()) {
    return(FALSE)
  }

  if (!is.null(message)) {
    ui_todo(message)
  }

  if (!rstudioapi::hasFun("openProject")) {
    return(FALSE)
  }

  if (ui_nope("Restart now?")) {
    return(FALSE)
  }

  rstudioapi::openProject(proj_get())
}

rstudio_git_tickle <- function() {
  if (rstudioapi::hasFun("executeCommand")) {
    rstudioapi::executeCommand("vcsRefresh")
  }
  invisible()
}
