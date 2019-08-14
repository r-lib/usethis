#' Create or modify the `Authors@R` field in the DESCRIPTION file
#'
#' @description If the `Authors@R` field is not included in the DESCRIPTION file
#' then `use_author()` adds the field assigns the author defined by the input
#' parameters. If the `Authors@R` field exists already in the DESCRIPTION then
#' `use_author()` will add the author defined by the input parameters as an
#' additional new author.
#'
#' The `use_author()` function should be used after [create_package()] or
#' [use_description()].
#'
#' If you create a lot of packages, consider storing personalized defaults as a
#' named list in an option named `"usethis.description"`. [use_description()]
#' will automatically fill using this information. Here's an example of code to
#' include in `.Rprofile`:
#'
#' ``` options( usethis.description = list( `Authors@R` = 'person("Jane", "Doe",
#' email = "jane@example.com", role = c("aut", "cre"), comment = c(ORCID =
#' "YOUR-ORCID-ID"))', License = "MIT + file LICENSE", Language =  "es" ) )
#' ```
#'
#' @param given a character string with the given (first) name of the author.
#' @param family a character string with the family (last) name of the author.
#' @param role a character vector specifying the role of the person to be added.
#' @param email a character string giving an e-mail address of the author to be added.
#' @param comment a character string providing comments related to the author to be added.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Adds the default Jane Doe to author
#'
#' use_author()
#'
#' # Adds the author information for Ali
#' use_author(
#'   given = "Ali",
#'   family = "Val",
#'   role = c("aut", "cre"),
#'   email = "alval@example.com",
#'   comment = c(ORCID = "YOUR-ORCID-ID")
#' )
#'
#' # Adds a second author Ali2
#' use_author(
#'   given = "Ali2",
#'   family = "Val2",
#'   role = c("cph", "fnd"),
#'   email = "alval2@example.com",
#'   comment = NULL
#' )
#' }


use_author <- function(given = "Jane", family = "Doe", role = c("aut", "cre"), email = "jane@example.com", comment = c(ORCID = "YOUR-ORCID-ID")) {
  # Adapted from use_dependency code and tools provided in the desc package
  # TODO long term: create addin to prompt for author information
  # TODO long term: create a snippet with author information for DESCRIPTION
  # TODO long term: add tests

  # Set the author as a person
  author <- utils::person(given = given, family = given, role = role, email = email, comment = comment)

  # Obtain the current DESCRIPTION fields
  current_desc_fields <- desc::desc_fields()

  # If the `Authors@R` is not a current field then add the field and fill in the author provided
  if (any(current_desc_fields == "Authors@R") == FALSE) {
    ui_done("`Authors@R` field added to DESCRIPTION and filled with {ui_value(author)}.")
    desc::desc_set_authors(
      authors = author,
      file = proj_get(),
      normalize = TRUE
    )
    return(invisible())
  } else if (any(current_desc_fields == "Authors@R") == TRUE) {
    # Obtain the current authors in the description
    desc_authors <- desc::desc_get_authors()

    # Check if any current author in the DESCRIPTION is exactly identical to the author input
    if (any(lapply(desc_authors, identical, author) == TRUE)) {
      ui_warn(
        "Author {ui_value(author)} is already listed in\\
        `Authors@R` in DESCRIPTION, no change made."
      )
    } else {
      ui_done("`Authors@R` field already exists adding {ui_value(author)} as an additional author.")
      desc::desc_add_author(given = given, family = given, role = role, email = email, comment = comment, normalize = TRUE)
      return(invisible())
    }
    # TODO check if the author input has partial overlap with one already
    # listed and ask user if they would like to add the person as a new author
    # or replace the existing author
  }
}
