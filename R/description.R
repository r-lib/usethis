#' Create a DESCRIPTION file
#'
#' @description
#' usethis consults the following sources, in this order, to set DESCRIPTION
#' fields:
#' * `fields` argument of [create_package()] or [use_description()]
#' * `getOption("usethis.description")` or `getOption("devtools.desc")`. The
#' devtools option is consulted only for backwards compatibility and it's
#' recommended to switch to an option named "usethis.description".
#' * Defaults built into usethis
#'
#' The fields discovered via options or the usethis package can be viewed with
#' `use_description_defaults()`.
#'
#' If you create a lot of packages, consider storing personalized defaults as a
#' named list in an option named `"usethis.description"`. Here's an example of
#' code to include in `.Rprofile`:
#'
#' ```
#' options(
#'   usethis.description = list(
#'     `Authors@R` = 'person("Jane", "Doe", email = "jane@example.com", role = c("aut", "cre"))',
#'     License = "MIT + file LICENSE",
#'     Language: es
#'   )
#' )
#' ```
#'
#' @param fields A named list of fields to add to DESCRIPTION, potentially
#'   overriding default values. See [use_description()] for how you can set
#'   personalized defaults using package options
#' @export
#' @examples
#' \dontrun{
#' use_description()
#'
#' use_description(fields = list(Language = "es"))
#'
#' use_description_defaults()
#' }
use_description <- function(fields = NULL) {
  name <- project_name()
  check_package_name(name)
  fields <- fields %||% list()
  check_is_named_list(fields)
  fields[["Package"]] <- name

  desc <- build_description(fields)
  write_over(proj_path("DESCRIPTION"), desc)
}

#' @rdname use_description
#' @export
use_description_defaults <- function() {
  list(
    usethis.description = getOption("usethis.description"),
    devtools.desc = getOption("devtools.desc"),
    usethis = list(
      Package = "valid.package.name.goes.here",
      Version = "0.0.0.9000",
      Title = "What the Package Does (One Line, Title Case)",
      Description = "What the package does (one paragraph).",
      "Authors@R" = 'person("First", "Last", , "first.last@example.com", c("aut", "cre"))',
      License = "What license it uses",
      Encoding = "UTF-8",
      LazyData = "true"
    )
  )
}

build_description <- function(fields = list()) {
  desc_list <- build_description_list(fields)

  # Collapse all vector arguments to single strings
  desc <- vapply(desc_list, collapse, character(1))

  glue("{names(desc)}: {desc}")
}

build_description_list <- function(fields = list()) {
  defaults <- use_description_defaults()
  defaults <- utils::modifyList(
    defaults$usethis,
    defaults$usethis.description %||% defaults$devtools.desc %||% list()
  )
  compact(utils::modifyList(defaults, fields))
}

check_package_name <- function(name) {
  if (!valid_name(name)) {
    stop_glue(
      "{value(name)} is not a valid package name. It should:\n",
      "* Contain only ASCII letters, numbers, and '.'\n",
      "* Have at least two characters\n",
      "* Start with a letter\n",
      "* Not end with '.'\n"
    )
  }

}

valid_name <- function(x) {
  grepl("^[[:alpha:]][[:alnum:].]+$", x) && !grepl("\\.$", x)
}
