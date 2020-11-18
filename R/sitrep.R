#' Report working directory and usethis/RStudio project
#'
#' @description `proj_sitrep()` reports
#'   * current working directory
#'   * the active usethis project
#'   * the active RStudio Project
#'
#' @description Call this function if things seem weird and you're not sure
#'   what's wrong or how to fix it. Usually, all three of these should coincide
#'   (or be unset) and `proj_sitrep()` provides suggested commands for getting
#'   back to this happy state.
#'
#' @return A named list, with S3 class `sitrep` (for printing purposes),
#'   reporting current working directory, active usethis project, and active
#'   RStudio Project
#' @export
#' @family project functions
#' @examples
#' proj_sitrep()
proj_sitrep <- function() {
  out <- list(
    working_directory = getwd(),
    active_usethis_proj = if (proj_active()) proj_get(),
    active_rstudio_proj = if (rstudioapi::hasFun("getActiveProject")) {
      rstudioapi::getActiveProject()
    }
    ## TODO(?): address home directory to help clarify fs issues on Windows?
    ## home_usethis = fs::path_home(),
    ## home_r = normalizePath("~")
  )
  out <- ifelse(map_lgl(out, is.null), out, as.character(path_tidy(out)))
  structure(out, class = "sitrep")
}

#' @export
print.sitrep <- function(x, ...) {
  keys <- format(names(x), justify = "right")
  purrr::walk2(keys, x, kv_line)

  rstudio_proj_is_active <- !is.null(x[["active_rstudio_proj"]])
  usethis_proj_is_active <- !is.null(x[["active_usethis_proj"]])

  rstudio_proj_is_not_wd <- rstudio_proj_is_active &&
    x[["working_directory"]] != x[["active_rstudio_proj"]]
  usethis_proj_is_not_wd <- usethis_proj_is_active &&
    x[["working_directory"]] != x[["active_usethis_proj"]]
  usethis_proj_is_not_rstudio_proj <- usethis_proj_is_active &&
    rstudio_proj_is_active &&
    x[["active_rstudio_proj"]] != x[["active_usethis_proj"]]

  if (rstudio_available() && !rstudio_proj_is_active) {
    ui_todo(
      "
      You are working in RStudio, but are not in an RStudio Project.
      A Project-based workflow offers many advantages. Read more at:
      {ui_field('https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects')}
      {ui_field('https://whattheyforgot.org/project-oriented-workflow.html')}
      "
    )
  }

  if (!usethis_proj_is_active) {
    ui_todo(
      "
      There is currently no active usethis project.
      usethis attempts to activate a project upon first need.
      Call {ui_code('proj_get()')} to initiate project discovery.
      Call {ui_code('proj_set(\"path/to/project\")')} or \\
      {ui_code('proj_activate(\"path/to/project\")')} to provide
      an explicit path.
      "
    )
  }

  if (usethis_proj_is_not_wd) {
    ui_todo(
      "
      Your working directory is not the same as the active usethis project.
      Set working directory to the project: {ui_code('setwd(proj_get())')}
      Set project to working directory:     {ui_code('proj_set(getwd())')}
      "
    )
  }

  if (rstudio_proj_is_not_wd) {
    ui_todo(
      "
      Your working directory is not the same as the active RStudio Project.
      Set working directory to the Project: {ui_code('setwd(rstudioapi::getActiveProject())')}
      "
    )
  }

  if (usethis_proj_is_not_rstudio_proj) {
    ui_todo(
      "
      Your active RStudio Project is not the same as the active usethis project.
      Set usethis project to RStudio Project: \\
      {ui_code('proj_set(rstudioapi::getActiveProject())')}
      Restart RStudio in the usethis project: \\
      {ui_code('rstudioapi::openProject(proj_get())')}
      Open the usethis project in a new instance of RStudio: \\
      {ui_code('proj_activate(proj_get())')}
      "
    )
  }

  invisible(x)
}
