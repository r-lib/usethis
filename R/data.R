#' Create package data
#'
#' `use_data` makes it easy to save package data in the correct format.
#' I recommend you save scripts that generate package data in `data-raw`:
#' use `use_data_raw` to set it up.
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
#' @param overwrite By default, `use_data` will not overwrite existing
#'   files. If you really want to do so, set this to `TRUE`.
#' @param compress Choose the type of compression used by [save()].
#'   Should be one of "gzip", "bzip2" or "xz".
#' @inheritParams use_template
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
                     base_path = ".") {
  objs <- get_objs_from_dots(dots(...))

  if (internal) {
    dir_name <- file.path(base_path, "R")
    paths <- file.path(dir_name, "sysdata.rda")
    objs <- list(objs)
  } else {
    dir_name <- file.path(base_path, "data")
    paths <- file.path(dir_name, paste0(objs, ".rda"))
  }

  check_data_paths(paths, overwrite)

  done("Saving ", unlist(objs), " to ", paths)

  envir <- parent.frame()
  mapply(
    save,
    list = objs,
    file = paths,
    MoreArgs = list(envir = envir, compress = compress)
  )

  invisible()
}

get_objs_from_dots <- function(.dots) {
  if (length(.dots) == 0L) {
    stop("Nothing to save", call. = FALSE)
  }

  is_name <- vapply(.dots, is.symbol, logical(1))
  if (any(!is_name)) {
    stop("Can only save existing named objects", call. = FALSE)
  }

  objs <- vapply(.dots, as.character, character(1))
  duplicated_objs <- which(stats::setNames(duplicated(objs), objs))
  if (length(duplicated_objs) > 0L) {
    objs <- unique(objs)
    warning("Saving duplicates only once: ",
            paste(names(duplicated_objs), collapse = ", "),
            call. = FALSE)
  }
  objs
}

check_data_paths <- function(paths, overwrite) {
  data_path <- dirname(paths[[1]])
  if (!file.exists(data_path)) dir.create(data_path)

  if (!overwrite) {
    paths_exist <- which(stats::setNames(file.exists(paths), paths))

    if (length(paths_exist) > 0L) {
      paths_exist <- unique(names(paths_exist))
      existing_names <- basename(paths_exist)
      stop(paste(existing_names, collapse = ", "), " already exists in ",
           dirname(paths_exist[[1L]]),
           ". ",
           "Use overwrite = TRUE to overwrite", call. = FALSE)
    }
  }
}


#' @rdname use_data
#' @export
use_data_raw <- function(base_path = ".") {
  use_directory("data-raw", ignore = TRUE, base_path = base_path)

  message("Next:")
  todo("Add data creation scripts in 'data-raw'")
  todo("Use devtools::use_data() to add data to package")
}
