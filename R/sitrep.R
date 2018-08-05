#' Report working directory and usethis/RStudio project
#'
#' @return A named list, with S3 class `sitrep` (for printing purposes),
#'   reporting current working directory, active usethis project, and active
#'   RStudio Project
#' @export
#'
#' @examples
#' proj_sitrep()
# should this be dr_proj()?
proj_sitrep <- function() {
  out <- list(
    working_directory = getwd(),
    active_usethis_proj = if (proj_active()) proj_get() else NULL,
    active_rstudio_proj = if (rstudioapi::hasFun("getActiveProject")) {
      rstudioapi::getActiveProject()
    } else NULL
    ## TODO(?): address home directory to help clarify fs issues on Windows?
    ## home_usethis = fs::path_home(),
    ## home_r = normalizePath("~")
  )
  out <- ifelse(lengths(out) > 0, fs::path_tidy(out), out)
  structure(out, class = "sitrep")
}

#' @export
format.sitrep <- function(x, ...) {
  max_width <- max(nchar(names(x)))
  format_string <- glue::glue("%{max_width}s")
  padded_names <- sprintf(format_string, names(x))
  glue::glue("
    {field(padded_names)}: \\
    {ifelse(lengths(x) > 0, value(x), unset(x))}\n"
  )
}

#' @export
print.sitrep <- function(x, ...) {
  out <- format(x)
  for (i in seq_along(x)) cat_line(out[[i]])

  cat_line()
  if (rstudioapi::isAvailable() && is.null(x[["active_rstudio_proj"]])) {
    todo("
         You are working in RStudio, but are not in an RStudio Project.
           A Project-based workflow offers many advantages. Read more at:
           https://support.rstudio.com/hc/en-us/articles/200526207-Using-Projects
           https://www.tidyverse.org/articles/2017/12/workflow-vs-script/
         ")
  }

  if (is.null(x[["active_usethis_proj"]])) {
    todo("
         There is currently no active usethis project.
           usethis attempts to activate a project upon first need.
           Call {code('proj_get()')} to explicitly initiate project activation.
         ")
  }

  if (!is.null(x[["active_usethis_proj"]]) &&
      x[["working_directory"]] != x[["active_usethis_proj"]]) {
    todo("
         Your working directory is not the same as the active usethis project.
           To set working directory to the project: {code('setwd(proj_get())')}
           To activate project in working directory: {code('proj_set(getwd())')}
         ")
  }

  if (!is.null(x[["active_rstudio_proj"]]) &&
      x[["working_directory"]] != x[["active_rstudio_proj"]]) {
    todo("
         Your working directory is not the same as the active RStudio Project.
           To set working directory to the Project: {code('setwd(rstudioapi::getActiveProject())')}
         ")
  }

  if (!is.null(x[["active_rstudio_proj"]]) &&
      !is.null(x[["active_rstudio_proj"]]) &&
      x[["active_rstudio_proj"]] != x[["active_usethis_proj"]]) {
    todo("
         Your active RStudio Project is not the same as the active usethis project.
           To set usethis project to RStudio Project: {code('proj_set(rstudioapi::getActiveProject())')}
         ")
  }

  invisible(x)
}
