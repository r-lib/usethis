#' Add an author to the `Authors@R` field in DESCRIPTION
#'
#' @description

#' `use_author()` adds a person to the `Authors@R` field of the DESCRIPTION
#' file, creating that field if necessary. It will not modify, e.g., the role(s)
#' or email of an existing author (judged using their "Given Family" name). For
#' that we recommend editing DESCRIPTION directly. Or, for programmatic use,
#' consider calling the more specialized functions available in the \pkg{desc}
#' package directly.
#'
#' `use_author()` also surfaces two other situations you might want to address:

#' * Explicit use of the fields `Author` or `Maintainer`. We recommend switching
#' to the more modern `Authors@R` field instead, because it offers richer
#' metadata for various downstream uses. (Note that `Authors@R` is *eventually*
#' processed to create `Author` and `Maintainer` fields, but only when the
#' `tar.gz` is built from package source.)

#' * Presence of the fake author placed by [create_package()] and
#' [use_description()]. This happens when \pkg{usethis} has to create a
#' DESCRIPTION file and the user hasn't given any author information via the
#' `fields` argument or the global option `"usethis.description"`. The
#' placeholder looks something like `First Last <first.last@example.com> [aut,
#' cre] (YOUR-ORCID-ID)` and `use_author()` offers to remove it in interactive
#' sessions.
#'
#' @inheritParams utils::person
#' @inheritDotParams utils::person
#' @export
#' @examples
#' \dontrun{
#' use_author(
#'   given = "Lucy",
#'   family = "van Pelt",
#'   role = c("aut", "cre"),
#'   email = "lucy@example.com",
#'   comment = c(ORCID = "LUCY-ORCID-ID")
#' )
#'
#' use_author("Charlie", "Brown")
#' }
#'
use_author <- function(given = NULL, family = NULL, ..., role = "ctb") {
  check_is_package("use_author()")
  maybe_name(given)
  maybe_name(family)
  check_character(role)

  d <- proj_desc()
  challenge_legacy_author_fields(d)
  # We only need to consider Authors@R

  authors_at_r_already <- d$has_fields("Authors@R")
  if (authors_at_r_already) {
    check_author_is_novel(given, family, d)
  }
  # This person is not already in Authors@R

  author <- utils::person(given = given, family = family, role = role, ...)
  aut_fmt <- format(author, style = 'text')
  if (authors_at_r_already) {
    ui_cli_bullets(c(
      "v" = "Adding to {.field Authors@R} in DESCRIPTION:",
      " " = "{aut_fmt}"
    ))
  } else {
    ui_cli_bullets(c(
      "v" = "Creating {.field Authors@R} field in DESCRIPTION and adding:",
      " " = "{aut_fmt}"
    ))
  }
  d$add_author(given = given, family = family, role = role, ...)

  challenge_default_author(d)

  d$write()

  invisible(TRUE)

}

challenge_legacy_author_fields <- function(d = proj_desc()) {
  has_legacy_field <- d$has_fields("Author") || d$has_fields("Maintainer")
  if (!has_legacy_field) {
    return(invisible())
  }

  ui_cli_bullets(c(
    "x" = "Found legacy {.field Author} and/or {.field Maintainer} field in
           DESCRIPTION.",
    " " = "usethis only supports modification of the {.field Authors@R} field.",
    "i" = "We recommend one of these paths forward:",
    "_" = "Delete the legacy fields and rebuild with {.fun use_author}; or",
    "_" = "Convert to {.field Authors@R} with
           {.fun desc::desc_coerce_authors_at_r}, then delete the legacy fields."
  ))
  if (ui_yeah("Do you want to cancel this operation and sort that out first?")) {
    usethis_abort("Cancelling.")
  }
  invisible()
}

check_author_is_novel <- function(given = NULL, family = NULL, d = proj_desc()) {
  authors <- d$get_authors()
  authors_given <- purrr::map(authors, "given")
  authors_family <- purrr::map(authors, "family")
  m <- purrr::map2_lgl(authors_given, authors_family, function(x, y) {
    identical(x, given) && identical(y, family)
  })
  if (any(m)) {
    aut_name <- glue("{given %||% ''} {family %||% ''}")
    usethis_abort(c(
      "x" = "{.val {aut_name}} already appears in {.field Authors@R}.",
      " " = "Please make the desired change directly in DESCRIPTION or call the
             {.pkg desc} package directly."
    ))
  }
  invisible()
}

challenge_default_author <- function(d = proj_desc()) {
  defaults <- usethis_description_defaults()
  default_author <- eval(parse(text = defaults[["Authors@R"]]))

  authors <- d$get_authors()
  m <- map_lgl(
    authors,
    # the `person` class is pretty weird!
    function(x) identical(x, unclass(default_author)[[1]])
  )

  if (any(m)) {
    ui_cli_bullets(c(
      "i" = "{.field Authors@R} appears to include a placeholder author:",
      " " = "{format(default_author, style = 'text')}"
    ))
    if(is_interactive() && ui_yeah("Would you like to remove it?")) {
      # TODO: Do I want to suppress this output?
      # Authors removed: First Last, NULL NULL.
      do.call(d$del_author, unclass(default_author)[[1]])
    }
  }

  return(invisible())
}
