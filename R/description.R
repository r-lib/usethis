#' Create a default DESCRIPTION file for a package.
#'
#' If you create a lot of packages, you can override the defaults by
#' setting option \code{"usethis.description"} to a named list.
#'
#' @param fields A named list of fields to add to \file{DESCRIPTION},
#'   potentially overriding the defaults. If \code{NULL}, retrieved from
#'   \code{getOption("usethis.description")}, and (for backward compatibility)
#'   from \code{getOption("devtools.desc")}.
#'   Arguments that take a list
#' @param base_path path to package root directory
#' @export
use_description <- function(fields = NULL,
                            base_path = ".") {

  name <- project_name(base_path = base_path)
  check_package_name(name)

  fields <- fields %||%
    getOption("usethis.description") %||%
    getOption("devtools.desc") %||%
    list()

  desc <- build_description(name, fields)
  write_over(base_path, "DESCRIPTION", desc)
}

build_description <- function(name, fields = list()) {
  desc_list <- build_description_list(name, fields)

  # Collapse all vector arguments to single strings
  desc <- vapply(desc_list, function(x) paste(x, collapse = ", "), character(1))

  paste0(names(desc), ": ", desc, "\n", collapse = "")
}

build_description_list <- function(name, fields = list()) {
  author <- getOption("devtools.desc.author") %||%
    'person("First", "Last", "first.last@example.com", c("aut", "cre"))'
  license <- getOption("devtools.desc.license") %||% "What license it uses"
  suggests <- getOption("devtools.desc.suggests")

  defaults <- list(
    Package = name,
    Version = "0.0.0.9000",
    Title = "What the Package Does (one line, title case)",
    Description = "What the package does (one paragraph).",
    "Authors@R" = author,
    Depends = paste0("R (>= ", as.character(getRversion()) ,")"),
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
      value(name), " is not a valid package name: it should contain only\n",
      "ASCII letters, numbers and dot, have at least two characters\n",
      "and start with a letter and not end in a dot.",
      call. = FALSE
    )
  }

}

valid_name <- function(x) {
  grepl("^[[:alpha:]][[:alnum:].]+$", x) && !grepl("\\.$", x)
}
