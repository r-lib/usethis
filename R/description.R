#' Create a default DESCRIPTION file for a package.
#'
#' @description
#' If you create a lot of packages, you can override the defaults by setting
#' option `"usethis.description"` to a named list. Here's an example of code one
#' could include in `.Rprofile`:
#'
#' ```
#' options(
#'   usethis.name = "Jane Doe",
#'   usethis.description = list(
#'     `Authors@R` = 'person("Jane", "Doe", email = "jane@example.com", role = c#' ("aut", "cre"))',
#'     License = "MIT + file LICENSE",
#'     Version = "0.0.0.9000"
#'   )
#' )
#' ```
#'
#' @param fields A named list of fields to add to \file{DESCRIPTION},
#'   potentially overriding the defaults. If `NULL`, retrieved from
#'   `getOption("usethis.description")`, and (for backward compatibility) from
#'   `getOption("devtools.desc")`.
#' @export
#' @examples
#' \dontrun{
#' use_description()
#' }
use_description <- function(fields = NULL) {
  name <- project_name()
  check_package_name(name)

  fields <- fields %||%
    getOption("usethis.description") %||%
    getOption("devtools.desc") %||%
    list()

  desc <- build_description(name, fields)
  write_over(proj_get(), "DESCRIPTION", desc)
}

build_description <- function(name, fields = list()) {
  desc_list <- build_description_list(name, fields)

  # Collapse all vector arguments to single strings
  desc <- vapply(desc_list, function(x) paste(x, collapse = ", "), character(1))

  paste0(names(desc), ": ", desc)
}

build_description_list <- function(name, fields = list()) {
  author <- getOption("devtools.desc.author") %||%
    'person("First", "Last", , "first.last@example.com", c("aut", "cre"))'
  license <- getOption("devtools.desc.license") %||% "What license it uses"
  suggests <- getOption("devtools.desc.suggests")

  defaults <- list(
    Package = name,
    Version = "0.0.0.9000",
    Title = "What the Package Does (One Line, Title Case)",
    Description = "What the package does (one paragraph).",
    "Authors@R" = author,
    License = license,
    Suggests = suggests,
    Encoding = "UTF-8",
    LazyData = "true",
    ByteCompile = "true"
  )

  # Override defaults with user supplied options
  desc <- utils::modifyList(defaults, fields)
  compact(desc)
}

check_package_name <- function(name) {
  if (!valid_name(name)) {
    stop(
      value(name), " is not a valid package name. It should:\n",
      "* Contain only ASCII letters, numbers, and '.'\n",
      "* Have at least two characters\n",
      "* Start with a letter\n",
      "* Not end with '.'\n",
      call. = FALSE
    )
  }

}

valid_name <- function(x) {
  grepl("^[[:alpha:]][[:alnum:].]+$", x) && !grepl("\\.$", x)
}
