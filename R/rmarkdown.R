
#' Add an RMarkdown Template
#'
#' @param template_name The name as printed in the template menu.
#' @param template_dir Name of the directory the template will live in within
#'   \code{inst/rmarkdown/templates}.
#' @param template_description A short description of the template.
#' @param template_create_dir Sets the value of \code{create_dir}
#'   in the template.yml
#' @inheritParams use_directory
#'
#' @export
#' @examples
#' \dontrun{
#' use_rmarkdown_template()
#' }
use_rmarkdown_template <- function(template_name = "Template Name",
                                   template_dir = slug(template_name),
                                   template_description = "A description of the template",
                                   template_create_dir = FALSE,
                                   base_path = ".") {

  # Process some of the inputs
  template_create_dir <- as.character(template_create_dir)
  template_dir <- file.path("inst", "rmarkdown", "templates", template_dir)

  # Scaffold files
  use_directory(file.path(template_dir, "skeleton"), base_path = base_path)
  use_template(
    "rmarkdown-template.yml",
    data = list(
      template_dir = template_dir,
      template_name = template_name,
      template_description = template_description,
      template_create_dir = template_create_dir
    ),
    save_as = file.path(template_dir, "template.yml"),
    base_path = base_path
  )

  use_template(
    "rmarkdown-template.Rmd",
    base_path = base_path,
    save_as = file.path(template_dir, "skeleton", "skeleton.Rmd")
  )


  invisible(TRUE)
}
