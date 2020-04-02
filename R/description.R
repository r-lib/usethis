#' Create or modify a DESCRIPTION file
#'
#' @description
#'
#' `use_description()` creates a `DESCRIPTION` file. Although mostly associated
#' with R packages, a `DESCRIPTION` file can also be used to declare
#' dependencies for a non-package projects. Within such a project,
#' [`devtools::install_deps()`] can then be used to install all the required
#' packages. Note that, by default, `use_decription()` checks for a
#' CRAN-compliant package name. You can turn this off with `check_name = FALSE`.
#'
#' usethis consults the following sources, in this order, to set `DESCRIPTION`
#' fields:
#' * `fields` argument of [create_package()] or [use_description()].
#' * `getOption("usethis.description")` or `getOption("devtools.desc")`. The
#' devtools option is consulted only for backwards compatibility and it's
#' recommended to switch to an option named "usethis.description".
#' * Defaults built into usethis.
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
#'     `Authors@R` = 'person("Jane", "Doe", email = "jane@example.com", role = c("aut", "cre"),
#'                           comment = c(ORCID = "YOUR-ORCID-ID"))',
#'     License = "MIT + file LICENSE",
#'     Language =  "es"
#'   )
#' )
#' ```
#'
#' @param fields A named list of fields to add to `DESCRIPTION`, potentially
#'   overriding default values. See [use_description()] for how you can set
#'   personalized defaults using package options
#' @param check_name Whether to check if the name is valid for CRAN and throw an
#'   error if not
#' @param roxygen If `TRUE`, sets `RoxygenNote` to current roxygen2 version.
#' @seealso The [description chapter](https://r-pkgs.org/description.html#dependencies)
#'   of [R Packages](https://r-pkgs.org).
#' @export
#' @examples
#' \dontrun{
#' use_description()
#'
#' use_description(fields = list(Language = "es"))
#'
#' use_description_defaults()
#' }
use_description <- function(fields = list(), check_name = TRUE, roxygen = TRUE) {
  name <- project_name()
  if (check_name) {
    check_package_name(name)
  }

  desc <- build_description(name, roxygen = roxygen, fields = fields)
  lines <- desc$str(by_field = TRUE, normalize = FALSE, mode = "file")

  write_over(proj_path("DESCRIPTION"), lines)
  if (!getOption("usethis.quiet", default = FALSE)) {
    print(desc)
  }
}

#' @rdname use_description
#' @param package Package name
#' @export
use_description_defaults <- function(package = NULL, roxygen = TRUE, fields = list()) {
  fields <- fields %||% list()
  check_is_named_list(fields)

  if (roxygen) {
    if (is_installed("roxygen2")) {
      roxygen_note <- utils::packageVersion("roxygen2")
    } else {
      roxygen_note <- "7.0.0" # version doesn't really matter
    }
  } else {
    roxygen_note <- NULL
  }

  usethis <- list(
    Package = package %||% "valid.package.name.goes.here",
    Version = "0.0.0.9000",
    Title = "What the Package Does (One Line, Title Case)",
    Description = "What the package does (one paragraph).",
    "Authors@R" = 'person("First", "Last", , "first.last@example.com", c("aut", "cre"), comment = c(ORCID = "YOUR-ORCID-ID"))',
    License = "`use_mit_license()`, `use_gpl3_license()` or friends to pick a license",
    Encoding = "UTF-8",
    LazyData = "true",
    Roxygen = "list(markdown = TRUE)",
    RoxygenNote = roxygen_note
  )

  options <- getOption("usethis.description") %||% getOption("devtools.desc") %||% list()

  defaults <- utils::modifyList(usethis, options)
  defaults <- utils::modifyList(defaults, fields)

  # Ensure each element is a single string
  if (inherits(defaults$`Authors@R`, "person")) {
    defaults$`Authors@R` <- format(defaults$`Authors@R`, style = "R")
    defaults$`Authors@R` <- paste0(defaults$`Authors@R`, collapse = "\n")
  }
  defaults <- lapply(defaults, paste, collapse = "")

  compact(defaults)
}

build_description <- function(package, roxygen = TRUE, fields = list()) {
  fields <- use_description_defaults(package, roxygen = roxygen, fields)

  desc <- desc::desc(text = glue("{names(fields)}: {fields}"))
  tidy_desc(desc)
  desc
}

check_package_name <- function(name) {
  if (!valid_package_name(name)) {
    ui_stop(c(
      "{ui_value(name)} is not a valid package name. To be allowed on CRAN, it should:",
      "* Contain only ASCII letters, numbers, and '.'",
      "* Have at least two characters",
      "* Start with a letter",
      "* Not end with '.'"
    ))
  }
}

valid_package_name <- function(x) {
  grepl("^[a-zA-Z][a-zA-Z0-9.]+$", x) && !grepl("\\.$", x)
}

tidy_desc <- function(desc) {
  # Alphabetise dependencies
  deps <- desc$get_deps()
  deps <- deps[order(deps$type, deps$package), , drop = FALSE]
  desc$del_deps()
  desc$set_deps(deps)

  # Alphabetise remotes
  remotes <- desc$get_remotes()
  if (length(remotes) > 0) {
    desc$set_remotes(sort(remotes))
  }

  desc$set("Encoding" = "UTF-8")

  # Normalize all fields (includes reordering)
  # Wrap in a try() so it always succeeds, even if user options are malformed
  try(desc$normalize(), silent = TRUE)
}
