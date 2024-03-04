#' Add minimal RStudio Addin binding
#'
#' This function helps you add a minimal
#' [RStudio Addin](https://rstudio.github.io/rstudioaddins/) binding to
#' `inst/rstudio/addins.dcf`.
#'
#' @param addin Name of the addin function, which should be defined in the
#' `R` folder.
#' @inheritParams use_template
#'
#' @export
use_addin <- function(addin = "new_addin", open = rlang::is_interactive()) {
  addin_dcf_path <- proj_path("inst", "rstudio", "addins.dcf")

  if (!file_exists(addin_dcf_path)) {
    create_directory(proj_path("inst", "rstudio"))
    file_create(addin_dcf_path)
    ui_bullets(c("v" = "Creating {.path {pth(addin_dcf_path)}}"))
  }

  addin_info <- render_template("addins.dcf", data = list(addin = addin))
  addin_info[length(addin_info) + 1] <- ""
  write_utf8(addin_dcf_path, addin_info, append = TRUE)
  ui_bullets(c(
    "v" = "Adding binding to {.fun {addin}} to {.path addins.dcf}"
  ))

  if (open) {
    edit_file(addin_dcf_path)
  }

  invisible(TRUE)
}
