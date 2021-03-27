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
#' @param version The serialization format version to use. The default, 2, was
#'   the default format from R 1.4.0 to 3.5.3. Version 3 became the default from
#'   R 3.6.0 and can only be read by R versions 3.5.0 and higher.
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
use_data <- function(...,
                     internal = FALSE,
                     overwrite = FALSE,
                     compress = "bzip2",
                     version = 2) {
  check_is_package("use_data()")

  objs <- get_objs_from_dots(dots(...))

  use_dependency("R", "depends", "2.10")
  if (internal) {
    use_directory("R")
    paths <- path("R", "sysdata.rda")
    objs <- list(objs)
  } else {
    use_directory("data")
    paths <- path("data", objs, ext = "rda")
    if (!desc::desc_has_fields("LazyData")) {
      ui_done("Setting {ui_field('LazyData')} to \\
              {ui_value('true')} in {ui_path('DESCRIPTION')}")
      desc::desc_set("LazyData", "true")
    }
  }
  check_files_absent(proj_path(paths), overwrite = overwrite)

  ui_done("Saving {ui_value(unlist(objs))} to {ui_value(paths)}")
  if (!internal) ui_todo("Document your data (see {ui_value('https://r-pkgs.org/data.html')})")

  envir <- parent.frame()
  mapply(
    save,
    list = objs,
    file = proj_path(paths),
    MoreArgs = list(envir = envir, compress = compress, version = version)
  )

  invisible()
}

get_objs_from_dots <- function(.dots) {
  if (length(.dots) == 0L) {
    ui_stop("Nothing to save.")
  }

  is_name <- vapply(.dots, is.symbol, logical(1))
  if (any(!is_name)) {
    ui_stop("Can only save existing named objects.")
  }

  objs <- vapply(.dots, as.character, character(1))
  duplicated_objs <- which(stats::setNames(duplicated(objs), objs))
  if (length(duplicated_objs) > 0L) {
    objs <- unique(objs)
    ui_warn("Saving duplicates only once: {ui_value(names(duplicated_objs))}")
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

  ui_stop(
    "
    {ui_path(paths[!ok])} already exist.,
    Use {ui_code('overwrite = TRUE')} to overwrite.
    "
  )
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
  stopifnot(is_string(name))
  r_path <- path("data-raw", asciify(name), ext = "R")
  use_directory("data-raw", ignore = TRUE)

  use_template(
    "packagename-data-prep.R",
    save_as = r_path,
    data = list(name = name),
    ignore = FALSE,
    open = open
  )

  ui_todo("Finish the data preparation script in {ui_value(r_path)}")
  ui_todo("Use {ui_code('usethis::use_data()')} to add prepared data to package")
}
