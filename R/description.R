#' Create or modify a DESCRIPTION file
#'
#' @description
#'

#' `use_description()` creates a `DESCRIPTION` file. Although mostly associated
#' with R packages, a `DESCRIPTION` file can also be used to declare
#' dependencies for a non-package project. Within such a project,
#' `devtools::install_deps()` can then be used to install all the required
#' packages. Note that, by default, `use_decription()` checks for a
#' CRAN-compliant package name. You can turn this off with `check_name = FALSE`.
#'

#' usethis consults the following sources, in this order, to set `DESCRIPTION`
#' fields:
#' * `fields` argument of [create_package()] or [use_description()]
#' * `getOption("usethis.description")`
#' * Defaults built into usethis
#'
#' The fields discovered via options or the usethis package can be viewed with
#' `use_description_defaults()`.
#'
#' If you create a lot of packages, consider storing personalized defaults as a
#' named list in an option named `"usethis.description"`. Here's an example of
#' code to include in `.Rprofile`, which can be opened via [edit_r_profile()]:
#'
#' ```
#' options(
#'   usethis.description = list(
#'     `Authors@R` = 'person("Jane", "Doe", email = "jane@example.com",
#'                           role = c("aut", "cre"),
#'                           comment = c(ORCID = "YOUR-ORCID-ID"))',
#'     License = "MIT + file LICENSE",
#'     Language =  "es"
#'   )
#' )
#' ```
#'
#' Prior to usethis v2.0.0, `getOption("devtools.desc")` was consulted for
#' backwards compatibility, but now only the `"usethis.description"` option is
#' supported.
#'
#' @param fields A named list of fields to add to `DESCRIPTION`, potentially
#'   overriding default values. See [use_description()] for how you can set
#'   personalized defaults using package options.
#' @param check_name Whether to check if the name is valid for CRAN and throw an
#'   error if not.
#' @param roxygen If `TRUE`, sets `RoxygenNote` to current roxygen2 version
#' @seealso The [description chapter](https://r-pkgs.org/description.html)
#'   of [R Packages](https://r-pkgs.org)
#' @export
#' @examples
#' \dontrun{
#' use_description()
#'
#' use_description(fields = list(Language = "es"))
#'
#' use_description_defaults()
#' }
use_description <- function(fields = list(),
                            check_name = TRUE,
                            roxygen = TRUE) {
  name <- project_name()
  if (check_name) {
    check_package_name(name)
  }

  desc <- build_description(name, roxygen = roxygen, fields = fields)

  tf <- withr::local_tempfile(pattern = glue("use_description-{name}-"))
  desc$write(file = tf)
  tf_contents <- read_utf8(tf)
  write_over(proj_path("DESCRIPTION"), tf_contents)

  # explicit check of "usethis.quiet" since I'm not doing the printing
  if (!getOption("usethis.quiet", default = FALSE)) {
    desc$print()
  }
}

#' @rdname use_description
#' @param package Package name
#' @export
use_description_defaults <- function(package = NULL,
                                     roxygen = TRUE,
                                     fields = list()) {
  fields <- fields %||% list()
  check_is_named_list(fields)

  usethis <- list(
    Package = package %||% "valid.package.name.goes.here",
    Version = "0.0.0.9000",
    Title = "What the Package Does (One Line, Title Case)",
    Description = "What the package does (one paragraph).",
    "Authors@R" = 'person("First", "Last", email = "first.last@example.com", role = c("aut", "cre"), comment = c(ORCID = "YOUR-ORCID-ID"))',
    License = "`use_mit_license()`, `use_gpl3_license()` or friends to pick a license",
    Encoding = "UTF-8"
  )

  if (roxygen) {
    if (is_installed("roxygen2")) {
      roxygen_note <- utils::packageVersion("roxygen2")
    } else {
      roxygen_note <- "7.0.0" # version doesn't really matter
    }
    usethis$Roxygen <- "list(markdown = TRUE)"
    usethis$RoxygenNote <- roxygen_note
  }

  options <- getOption("usethis.description") %||% list()

  # A `person` object in Authors@R is not patched in by modifyList()
  modify_this <- function(orig, patch) {
    out <- utils::modifyList(orig, patch)
    if (inherits(patch$`Authors@R`, "person")) {
    #if (has_name(patch, "Authors@R")) {
      out$`Authors@R` <- patch$`Authors@R`
    }
    out
  }

  defaults <- modify_this(usethis, options)
  defaults <- modify_this(defaults, fields)

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
  desc$set("Encoding" = "UTF-8")

  # Normalize all fields (includes reordering)
  # Wrap in a try() so it always succeeds, even if user options are malformed
  try(desc$normalize(), silent = TRUE)
}

# 2021-10-10, while adding use_description_list(), I moved this helper here
#
# this helper feels out-of-sync with current usethis practices around active
# project and how overwrite is handled
#
# I won't change use_description_field() now, but use_description_list() is
# implemented differently, more in keeping with our current style
use_description_field <- function(name, value, overwrite = FALSE) {
  # account for `value`s produced via `glue::glue()`
  value <- as.character(value)
  curr <- desc::desc_get(name, file = proj_get())[[1]]
  curr <- gsub("^\\s*|\\s*$", "", curr)

  if (identical(curr, value)) {
    return(invisible())
  }

  if (!is.na(curr) && !overwrite) {
    ui_stop(
      "{ui_field(name)} has a different value in DESCRIPTION. \\
      Use {ui_code('overwrite = TRUE')} to overwrite."
    )
  }

  ui_done("Setting {ui_field(name)} field in DESCRIPTION to {ui_value(value)}")
  desc::desc_set(name, value, file = proj_get())
  invisible()
}

use_description_list <- function(key,
                                 values,
                                 append = TRUE,
                                 desc = NULL) {
  desc_provided <- !is.null(desc)
  desc <- desc %||% desc::desc(file = proj_get())
  check_string(key)
  stopifnot(is.character(values))

  if (append) {
    values <- unique(c(desc$get_list(key, default = ""), values))
  }
  # formatting needs some improvements
  # https://github.com/r-lib/desc/issues/117
  desc$set_list(key, values, sep = ",\n")

  if (desc_provided) {
    return(invisible())
  }

  tf <- withr::local_tempfile(
    pattern = glue("use_description_list-{project_name()}-{path_sanitize(key, '-')}")
  )
  desc$write(file = tf)
  tf_contents <- read_utf8(tf)
  write_over(proj_path("DESCRIPTION"), tf_contents)
}
