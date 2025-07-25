#' Document Data
#'
#' @description
#' `use_document_data()` creates an .R file containing detailed documentation
#' of a provided data set. It automatically generates a roxygen template including
#' variables' names, data types, row and column counts, and placeholders for further description.
#'
#' @param .data A data set loaded in the R environment. The function extracts its
#' name, type, class, dimensions, and column names for documentation.
#' @param path The directory where the documentation file will be saved. Defaults to the current working directory.
#' @param overwrite Logical, whether to overwrite an existing file with the same name. Defaults to `FALSE`.
#' @param description A character string for the data set description. Defaults to "Describe your data set here".
#' @param source A character string indicating the source of the data set. Defaults to "Add your source here".
#'
#' @return Invisibly returns the file path where the documentation was saved.
#'
#' @export
#' @examples
#' \dontrun{
#' the_data <- as.data.frame(datasets::Titanic)
#' use_document_data(the_data)
#' }
use_document_data <- function(.data, path = ".", overwrite = FALSE,
                              description = "Describe your dataset here",
                              source = "Add your source here") {
  dataset_name <- rlang::as_name(rlang::enquo(.data))

  if (!inherits(.data, "data.frame")) {
    ui_abort("The provided object is not a data frame.")
  }

  file_path <- fs::path(path, paste0(dataset_name, ".R"))

  if (fs::file_exists(file_path) && !overwrite) {
    ui_abort(paste0("File '", file_path, "' already exists. Use `overwrite = TRUE` to overwrite it."))
  }

  data_description <- create_data_description(.data, dataset_name, description, source)
  cat(data_description, file = file_path)

  ui_bullets(c(
    "*" = paste0("Documentation file created: ", pth(file_path), "."),
    "_" = "Finish writing the data documentation in the generated file."
  ))

  invisible(file_path)
}

#' Create Data Description
#'
#' @description
#' Generates a description of a data set, including information about
#' its type, class, dimensions (rows and columns), and a placeholder for each
#' variable's description. This description is formatted as a string that could
#' be used directly in R documentation files or other descriptive materials.
#'
#' @param dataset A data frame for which the description is to be generated.
#' @param name The name of the data set, which will be used in the title and usage
#'        sections of the generated description.
#' @param description A character string for the data set description.
#' @param source A character string indicating the source of the data set.
#'
#' @return A character string containing the structured documentation template
#'         for the data set. This includes the data set's basic information and
#'         placeholders for detailed descriptions of each variable.
#'
#' @keywords internal
#'
create_data_description <- function(dataset, name, description, source) {
  data_info <- generate_data_info(dataset)
  variable_descriptions <- generate_variable_descriptions(dataset)

  description_template <- paste0(
    "#' @title ", name, "\n",
    "#' @description ", description, "\n",
    "#' @docType data\n",
    "#' @usage data(", name, ")\n",
    "#' @format ", data_info,
    "#' \\itemize{\n",
    "#' ", paste(variable_descriptions, collapse = "\n#' "), "\n#' }\n",
    "#' @source ", source, "\n",
    "'", name, "'"
  )

  return(description_template)
}

generate_data_info <- function(dataset) {
  paste0(
    "A ", typeof(dataset), " [", class(dataset), "] with ",
    nrow(dataset), " rows and ", length(names(dataset)), " variables:\n"
  )
}

generate_variable_descriptions <- function(dataset) {
  purrr::map_chr(names(dataset), function(var) {
    paste0("\\item{", var, "} {", class(dataset[[var]]), ": Type label here}")
  })
}
