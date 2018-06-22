#' Create package data
#'
#' `use_data()` makes it easy to save package data in the correct format.
#' I recommend you save scripts that generate package data in `data-raw`:
#' use `use_data_raw()` to set it up.
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
                     compress = "bzip2") {
  check_is_package("use_data()")

  objs <- get_objs_from_dots(dots(...))

  if (internal) {
    use_directory("R")
    paths <- path("R", "sysdata.rda")
    objs <- list(objs)
  } else {
    use_directory("data")
    paths <- path("data", objs, ext = "rda")
  }
  check_files_absent(proj_path(paths), overwrite = overwrite)

  done("Saving {collapse(value(unlist(objs)))} to {collapse(value(paths))}")

  envir <- parent.frame()
  mapply(
    save,
    list = objs,
    file = proj_path(paths),
    MoreArgs = list(envir = envir, compress = compress)
  )

  invisible()
}

get_objs_from_dots <- function(.dots) {
  if (length(.dots) == 0L) {
    stop_glue("Nothing to save.")
  }

  is_name <- vapply(.dots, is.symbol, logical(1))
  if (any(!is_name)) {
    stop_glue("Can only save existing named objects.")
  }

  objs <- vapply(.dots, as.character, character(1))
  duplicated_objs <- which(stats::setNames(duplicated(objs), objs))
  if (length(duplicated_objs) > 0L) {
    objs <- unique(objs)
    warning_glue(
      "Saving duplicates only once: {collapse(names(duplicated_objs))}"
    )
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

  stop_glue(
    "{collapse(value(paths[!ok]))} already exist. ",
    "Use {code('overwrite = TRUE')} to overwrite."
  )
}


#' @rdname use_data
#' @export
use_data_raw <- function() {
  use_directory("data-raw", ignore = TRUE)

  message("Next:")
  todo("Add data creation scripts in {value('data-raw/')}")
  todo("Use {code('usethis::use_data()')} to add data to package")
}
