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
  out <- ifelse(is_null(out), out, fs::path_tidy(out))
  structure(out, class = "sitrep")
}

#' @export
format.sitrep <- function(x, ...) {
  unset <- function(...) {
    x <- paste0(...)
    crayon::make_style("lightgrey")(x)
  }

  keys <- purrr::map_chr(format(names(x), justify = "right"), ui_field)
  vals <- ifelse(is_null(x), unset(x), purrr::map(x, ui_value))
  glue::glue("{keys}: {vals}")
}

#' @export
print.sitrep <- function(x, ...) {
  out <- format(x)
  cat_line(out)

  if (rstudioapi::isAvailable() && is.null(x[["active_rstudio_proj"]])) {
    ui_todo(
      "
      You are working in RStudio, but are not in an RStudio Project.
      A Project-based workflow offers many advantages. Read more at:
      https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects
      https://www.tidyverse.org/articles/2017/12/workflow-vs-script/
      "
    )
  }

  if (is.null(x[["active_usethis_proj"]])) {
    ui_todo(
      "
      There is currently no active usethis project.
      usethis attempts to activate a project upon first need.
      Call {ui_code('proj_get()')} to explicitly initiate project activation.
      "
    )
  }

  if (!is.null(x[["active_usethis_proj"]]) &&
      x[["working_directory"]] != x[["active_usethis_proj"]]) {
    ui_todo(
      "
      Your working directory is not the same as the active usethis project.
      To set working directory to the project: {ui_code('setwd(proj_get())')}
      To activate project in working directory: {ui_code('proj_set(getwd())')}
      "
    )
  }

  if (!is.null(x[["active_rstudio_proj"]]) &&
      x[["working_directory"]] != x[["active_rstudio_proj"]]) {
    ui_todo(
      "
      Your working directory is not the same as the active RStudio Project.
      To set working directory to the Project: {ui_code('setwd(rstudioapi::getActiveProject())')}
      "
    )
  }

  if (!is.null(x[["active_rstudio_proj"]]) &&
      !is.null(x[["active_usethis_proj"]]) &&
      x[["active_rstudio_proj"]] != x[["active_usethis_proj"]]) {
    ui_todo(
      "
      Your active RStudio Project is not the same as the active usethis project.
      To set usethis project to RStudio Project: {ui_code('proj_set(rstudioapi::getActiveProject())')}
      "
    )
  }

  invisible(x)
}

is_null <- function(x) vapply(x, is.null, logical(1))
