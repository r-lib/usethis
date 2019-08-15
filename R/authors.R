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
  # TODO long term: figure out if/how desc package requires input for role with multiple roles (i.e. c("aut", "cre"))
  # TODO long term: create addin to prompt for author information
  # TODO long term: create a snippet with author information for DESCRIPTION
  # TODO add tests

  # Assume DESCRIPTION is generated from usethis so that Authors@R is filled with either
  # 1. The temporary author filled in without usethis defaults
  # person("First", "Last", , "first.last@example.com", c("aut", "cre"), comment = c(ORCID = "YOUR-ORCID-ID"))
  # 2. True author(s)

  # Check the "Author:" field exists and if it does error the function
  if (desc::desc_has_fields("Author")) {
    ui_stop(
      "{ui_field('Author')} was found as a field value in the DESCRIPTION. \\
       Please remove or replace it with the {ui_field('Authors@R')} field."
    )
    # TODO long term: if Author: is found in the description ask user if they
    # want to remove and replace it with Authors@R using desc::desc_del()
  }


  # TODO long term: if Authors@R field is missing from the description ask user
  # if they want to add a blank one or error our
  # if(desc::desc_has_fields("Authors@R") == FALSE){
  #   desc::desc_set(`Authors@R` = '')
  # }

  # Create person object using inputs
  author <- utils::person(given = given, family = family, role = role, email = email, comment = comment)

  # Obtain the current authors in the description
  desc_authors <- desc::desc_get_authors()

  # Check if any current author in the DESCRIPTION is exactly identical to the author input
  if (author %in% desc_authors) {
    ui_stop(
      "Author {ui_value(author)} is already listed in \\
      {ui_field('Authors@R')} in the current DESCRIPTION, no change made."
    )
  }

  # Add the input author
  desc::desc_add_author(given = given, family = family, role = role, email = email, comment = comment, normalize = TRUE)
  ui_done("Added {ui_value(author)} to the {ui_field('Authors@R')} field.")

  # Check if the usethis default author is included and remove it if so
  usethis_author <- utils::person(given = "First", family = "Last", role = c("aut", "cre"), email = "first.last@example.com", comment = c(ORCID = "YOUR-ORCID-ID"))

  if (usethis_author %in% desc_authors) {
    if (ui_yeah("{ui_field('Authors@R')}` field is populated with the {ui_code('usethis')} \\
               default (i.e. {ui_value(usethis_author)}. Would you like to remove the default?")) {
      # TODO(@jennybc): should we suppress messages from the desc::desc_del_author function? If so, how is this handled inside the package? suppressMessages()?
      # Delete the usethis default author (i.e. person(given = "First", family = "Last", email = "first.last@example.com", comment = c(ORCID = "YOUR-ORCID-ID")))
      desc::desc_del_author(given = "First", family = "Last", email = "first.last@example.com", comment = c(ORCID = "YOUR-ORCID-ID"))
    }
  }

  return(invisible())
}
