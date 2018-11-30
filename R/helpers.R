use_description_field <- function(name,
                                  value,
                                  base_path = proj_get(),
                                  overwrite = FALSE) {
  curr <- desc::desc_get(name, file = base_path)[[1]]
  if (identical(curr, value)) {
    return(invisible())
  }

  if (!is.na(curr) && !overwrite) {
    stop_glue(
      "{field(name)} has a different value in DESCRIPTION. ",
      "Use {code('overwrite = TRUE')} to overwrite."
    )
  }

  done("Setting {field(name)} field in DESCRIPTION to {value(value)}")
  desc::desc_set(name, value, file = base_path)
  invisible()
}

use_dependency <- function(package, type, min_version = NULL) {
  stopifnot(is_string(package))
  stopifnot(is_string(type))

  if (package != "R" && !requireNamespace(package, quietly = TRUE)) {
    stop_glue(
      "{value(package)} must be installed before you can ",
      "take a dependency on it."
    )
  }

  if (isTRUE(min_version)) {
    min_version <- utils::packageVersion(package)
  }
  version <- if (is.null(min_version)) "*" else paste0(">= ", min_version)

  types <- c("Depends", "Imports", "Suggests", "Enhances", "LinkingTo")
  names(types) <- tolower(types)
  type <- types[[match.arg(tolower(type), names(types))]]

  deps <- desc::desc_get_deps(proj_get())

  existing_dep <- deps$package == package
  existing_type <- deps$type[existing_dep]
  existing_ver <- deps$version[existing_dep]
  is_linking_to <- (existing_type != "LinkingTo" && type == "LinkingTo") ||
    (existing_type == "LinkingTo" && type != "LinkingTo")

  # No existing dependecy, so can simply add
  if (!any(existing_dep) || is_linking_to) {
    done("Adding {value(package)} to {field(type)} field in DESCRIPTION")
    desc::desc_set_dep(package, type, version = version, file = proj_get())
    return(invisible())
  }

  delta <- sign(match(existing_type, types) - match(type, types))
  if (delta < 0) {
    # don't downgrade
    warning_glue(
      "Package {value(package)} is already listed in ",
      "{value(existing_type)} in DESCRIPTION, no change made."
    )
  } else if (delta == 0 && !is.null(min_version)) {
    # change version
    upgrade <- existing_ver == "*" || numeric_version(min_version) > version_spec(existing_ver)
    if (upgrade) {
      done(
        "Increasing {value(package)} version to {value(version)} in DESCRIPTION"
      )
      desc::desc_set_dep(package, type, version = version, file = proj_get())
    }
  } else if (delta > 0) {
    # upgrade
    if (existing_type != "LinkingTo") {
      done(
        "Moving {value(package)} from {field(existing_type)} to {field(type)}",
        " field in DESCRIPTION"
      )
      desc::desc_del_dep(package, existing_type, file = proj_get())
      desc::desc_set_dep(package, type, version = version, file = proj_get())
    }
  }

  invisible()
}

version_spec <- function(x) {
  x <- gsub("(<=|<|>=|>|==)\\s*", "", x)
  numeric_version(x)
}

view_url <- function(..., open = interactive()) {
  url <- paste(..., sep = "/")
  if (open) {
    done("Opening URL {url}")
    utils::browseURL(url)
  } else {
    todo("Open URL {url}")
  }
  invisible(url)
}
