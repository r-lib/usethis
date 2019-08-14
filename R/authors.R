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
#' email = "jane@example.com", role = "aut", comment = c(ORCID =
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
#'   role = "aut",
#'   email = "alval@example.com",
#'   comment = c(ORCID = "YOUR-ORCID-ID")
#' )
#'
#' # Adds a second author Ali2
#' use_author(
#'   given = "Ali2",
#'   family = "Val2",
#'   role = "cph",
#'   email = "alval2@example.com",
#'   comment = NULL
#' )
#' }
#'
use_author <- function(given = "Jane", family = "Doe", role = "aut", email = "jane@example.com", comment = c(ORCID = "YOUR-ORCID-ID")) {
  # Adapted from use_dependency code and tools provided in the desc package
  # TODO figure out how desc package requires input for role with multiple roles
  # TODO long term: create addin to prompt for author information
  # TODO long term: create a snippet with author information for DESCRIPTION
  # TODO add tests

  # Assume DESCRIPTION is generated from usethis so that Authors@R is filled with either
  # 1. The temporary author filled in without usethis defaults
  # person("First", "Last", , "first.last@example.com", c("aut", "cre"), comment = c(ORCID = "YOUR-ORCID-ID"))
  # 2. True author(s)
  # TODO long term: make function more robust to fill in author even when usethis did not generate the DESCRIPTION

  fields <- desc::desc_fields(file = proj_get())

  # Check the author field exists
  if ("Author" %in% fields) {
    ui_stop(
      "Author was found as a field value in the DESCRIPTION. \\
       Please remove or replace it with `Authors@R` before continuing."
    )
  }

  # Create person object using inputs
  author <- utils::person(given = given, family = given, role = role, email = email, comment = comment)

  # Obtain the current authors in the description
  desc_authors <- desc::desc_get_authors(file = proj_get())

  # Check if the input author already exists as an author
  if (any(lapply(desc_authors, identical, author) == TRUE)) {
    ui_stop(
      "Author {ui_value(author)} is already listed in \\
       `Authors@R` in DESCRIPTION, no change made."
    )
  }

  # Check if any current author in the DESCRIPTION is exactly identical to the author input
  if (any(lapply(desc_authors, identical, author) == TRUE)) {
    ui_stop(
      "Author {ui_value(author)} is already listed in\\
        `Authors@R` in DESCRIPTION, no change made."
    )
  }

  # Add the input author
  desc::desc_add_author(given = given, family = family, role = role, email = email, comment = comment, file = proj_get(), normalize = TRUE)
  ui_done("`Authors@R` field already exists adding {ui_value(author)} as an additional author.")

  # Check if the usethis default author is included and remove it if so
  usethis_author <- utils::person("First", "Last", , "first.last@example.com", comment = c(ORCID = "YOUR-ORCID-ID"))

  if (author %in% desc_authors) {
    desc::desc_del_author(given = "First", family = "Last", email = "first.last@example.com", comment = c(ORCID = "YOUR-ORCID-ID"), file = proj_get())
  }

  return(invisible())
}
