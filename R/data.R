#' Create package data
#'
#' `use_data()` makes it easy to save package data in the correct format. I
#' recommend you save scripts that generate package data in `data-raw`: use
#' `use_data_raw()` to set it up. You also need to document exported datasets.
#'
#' @param ... Unquoted names of existing objects to save.
#' @param internal If `FALSE`, saves each object in its own `.rda`
#'   file in the `data/` directory. These data files bypass the usual
#'   export mechanism and are available whenever the package is loaded
#'   (or via [data()] if `LazyData` is not true).
#'
#'   If `TRUE`, stores all objects in a single `R/sysdata.rda` file.
#'   Objects in this file follow the usual export rules. Note that this means
#'   they will be exported if you are using the common `exportPattern()`
#'   rule which exports all objects except for those that start with `.`.
#' @param overwrite By default, `use_data()` will not overwrite existing
#'   files. If you really want to do so, set this to `TRUE`.
#' @param compress Choose the type of compression used by [save()].
#'   Should be one of "gzip", "bzip2", or "xz".
#' @param version The serialization format version to use. The default, 3, can
#'   only be read by R versions 3.5.0 and higher. For R 1.4.0 to 3.5.3, use
#'   version 2.
#' @inheritParams base::save
#'
#' @seealso The [data chapter](https://r-pkgs.org/data.html) of [R
#'   Packages](https://r-pkgs.org).
#' @export
#' @examples
#' \dontrun{
#' x <- 1:10
#' y <- 1:100
#'
#' use_data(x, y) # For external use
#' use_data(x, y, internal = TRUE) # For internal use
#' }
use_data <- function(
  ...,
  internal = FALSE,
  overwrite = FALSE,
  compress = "bzip2",
  version = 3,
  ascii = FALSE
) {
  check_is_package("use_data()")

  objs <- get_objs_from_dots(dots(...))

  original_minimum_r_version <- pkg_minimum_r_version()
  serialization_minimum_r_version <- if (version < 3) "2.10" else "3.5"
  if (
    is.na(original_minimum_r_version) ||
      original_minimum_r_version < serialization_minimum_r_version
  ) {
    use_dependency("R", "depends", serialization_minimum_r_version)
  }

  if (internal) {
    use_directory("R")
    paths <- path("R", "sysdata.rda")
    objs <- list(objs)
  } else {
    use_directory("data")
    paths <- path("data", objs, ext = "rda")
    desc <- proj_desc()

    if (!desc$has_fields("LazyData")) {
      ui_bullets(c(
        "v" = "Setting {.field LazyData} to {.val true} in {.path DESCRIPTION}."
      ))
      desc$set(LazyData = "true")
      desc$write()
    }
  }
  check_files_absent(proj_path(paths), overwrite = overwrite)

  ui_bullets(c(
    "v" = "Saving {.val {unlist(objs)}} to {.val {paths}}."
  ))
  if (!internal) {
    ui_bullets(c(
      "_" = "Document your data (see {.url https://r-pkgs.org/data.html})."
    ))
  }

  envir <- parent.frame()
  mapply(
    save,
    list = objs,
    file = proj_path(paths),
    MoreArgs = list(
      envir = envir,
      compress = compress,
      version = version,
      ascii = ascii
    )
  )

  invisible()
}

get_objs_from_dots <- function(.dots) {
  if (length(.dots) == 0L) {
    ui_abort("Nothing to save.")
  }

  is_name <- vapply(.dots, is.symbol, logical(1))
  if (!all(is_name)) {
    ui_abort("Can only save existing named objects.")
  }

  objs <- vapply(.dots, as.character, character(1))
  duplicated_objs <- which(stats::setNames(duplicated(objs), objs))
  if (length(duplicated_objs) > 0L) {
    objs <- unique(objs)
    ui_bullets(c(
      "!" = "Saving duplicates only once: {.val {names(duplicated_objs)}}."
    ))
  }
  objs
}

check_files_absent <- function(paths, overwrite) {
  if (overwrite) {
    return()
  }

  ok <- !file_exists(paths)

  if (all(ok)) {
    return()
  }

  ui_abort(c(
    "{.path {pth(paths[!ok])}} already exist.",
    "Use {.code overwrite = TRUE} to overwrite."
  ))
}

#' @param name Name of the dataset to be prepared for inclusion in the package.
#' @inheritParams use_template
#' @rdname use_data
#' @export
#' @examples
#' \dontrun{
#' use_data_raw("daisy")
#' }
use_data_raw <- function(name = "DATASET", open = rlang::is_interactive()) {
  check_name(name)
  r_path <- path("data-raw", asciify(name), ext = "R")
  use_directory("data-raw", ignore = TRUE)

  use_template(
    "packagename-data-prep.R",
    save_as = r_path,
    data = list(name = name),
    ignore = FALSE,
    open = open
  )

  ui_bullets(c(
    "_" = "Finish writing the data preparation script in {.path {pth(r_path)}}.",
    "_" = "Use {.fun usethis::use_data} to add prepared data to package."
  ))
}
