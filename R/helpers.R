use_description_field <- function(name,
                                  value,
                                  base_path = proj_get(),
                                  overwrite = FALSE) {
  curr <- desc::desc_get(name, file = base_path)[[1]]
  if (identical(curr, value)) {
    return(invisible())
  }

  if (!is.na(curr) && !overwrite) {
    stop(
      field(name), " has a different value in DESCRIPTION. ",
      "Use overwrite = TRUE to overwrite.",
      call. = FALSE
    )
  }

  done("Setting ", field(name), " field in DESCRIPTION to ", value(value))
  desc::desc_set(name, value, file = base_path)
  invisible()
}

use_dependency <- function(package, type, version = "*") {
  stopifnot(is_string(package))
  stopifnot(is_string(type))

  if (package != "R" && !requireNamespace(package, quietly = TRUE)) {
    stop(
      value(package),
      " must be installed before you can take a dependency on it",
      call. = FALSE
    )
  }

  types <- c("Depends", "Imports", "Suggests", "Enhances", "LinkingTo")
  names(types) <- tolower(types)
  type <- types[[match.arg(tolower(type), names(types))]]

  deps <- desc::desc_get_deps(proj_get())

  existing_dep <- deps$package == package
  existing_type <- deps$type[existing_dep]

  if (
    !any(existing_dep) ||
    (existing_type != "LinkingTo" && type == "LinkingTo")
  ) {
    done("Adding ", value(package), " to ", field(type), " field in DESCRIPTION")
    desc::desc_set_dep(package, type, version = version, file = proj_get())
    return(invisible())
  }

  ## no downgrades
  if (match(existing_type, types) < match(type, types)) {
    warning(
      "Package ", value(package), " is already listed in ",
      value(existing_type), " in DESCRIPTION, no change made.",
      call. = FALSE
    )
    return(invisible())
  }

  if (match(existing_type, types) > match(type, types)) {
    if (existing_type != "LinkingTo") {
      ## prepare for an upgrade
      done(
        "Removing ", value(package), " from ", field(existing_type),
        " field in DESCRIPTION"
      )
      desc::desc_del_dep(package, existing_type, file = proj_get())
    }
  } else {
    ## maybe change version?
    to_version <- any(existing_dep & deps$version != version)
    if (to_version) {
      done(
        "Setting ", value(package), " version to ",
        field(version), " field in DESCRIPTION"
      )
      desc::desc_set_dep(package, type, version = version, file = proj_get())
    }
    return(invisible())
  }

  done(
    "Adding ", value(package), " to ", field(type), " field in DESCRIPTION",
    if (version != "*") ", with version ", field(version)
  )
  desc::desc_set_dep(package, type, version = version, file = proj_get())

  invisible()
}

view_url <- function(..., open = interactive()) {
  url <- paste(..., sep = "/")
  if (open) {
    done("Opening url")
    utils::browseURL(url)
  } else {
    todo("Open url ", url)
  }
  invisible(url)
}
