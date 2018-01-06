#' Add an RMarkdown Template
#'
#' Adds files and directories necessary to add a custom rmarkdown template to
#' RStudio. It creates:
#' * `inst/rmarkdown/templates/{{template_dir}}`. Main directory.
#' * `skeleton/skeleton.Rmd`. Your template Rmd file.
#' * `template.yml` with basic information filled in.
#'
#' @param template_name The name as printed in the template menu.
#' @param template_dir Name of the directory the template will live in within
#'   `inst/rmarkdown/templates`.
#' @param template_description Sets the value of `description` in
#'   `template.yml`.
#' @param template_create_dir Sets the value of `create_dir` in `template.yml`.
#'
#' @export
#' @examples
#' \dontrun{
#' use_rmarkdown_template()
#' }
use_rmarkdown_template <- function(template_name = "Template Name",
                                   template_dir = slug(template_name, ""),
                                   template_description = "A description of the template",
                                   template_create_dir = FALSE) {

  # Process some of the inputs
  template_create_dir <- as.character(template_create_dir)
  template_dir <- file.path("inst", "rmarkdown", "templates", template_dir)

  # Scaffold files
  use_directory(file.path(template_dir, "skeleton"))
  use_template(
    "rmarkdown-template.yml",
    data = list(
      template_dir = template_dir,
      template_name = template_name,
      template_description = template_description,
      template_create_dir = template_create_dir
    ),
    save_as = file.path(template_dir, "template.yml")
  )

  use_template(
    "rmarkdown-template.Rmd",
    file.path(template_dir, "skeleton", "skeleton.Rmd")
  )

  invisible(TRUE)
}
