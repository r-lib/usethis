use_dependency <- function(package, type, min_version = NULL) {
  check_name(package)
  check_name(type)

  if (package != "R") {
    check_installed(package)
  }

  if (package == "R" && tolower(type) != "depends") {
    ui_stop("Set {ui_code('type = \"Depends\"')} when specifying an R version")
  } else if (package == "R" && is.null(min_version)) {
    ui_stop("Specify {ui_code('min_version')} when {ui_code('package = \"R\"')}")
  }

  if (isTRUE(min_version) && package == "R") {
    min_version <- r_version()
  } else if (isTRUE(min_version)) {
    min_version <- utils::packageVersion(package)
  }
  version <- if (is.null(min_version)) "*" else glue(">= {min_version}")

  types <- c("Depends", "Imports", "Suggests", "Enhances", "LinkingTo")
  names(types) <- tolower(types)
  type <- types[[match.arg(tolower(type), names(types))]]

  desc <- proj_desc()
  deps <- desc$get_deps()

  existing_dep <- deps$package == package
  existing_type <- deps$type[existing_dep]
  existing_ver <- deps$version[existing_dep]
  is_linking_to <- (existing_type != "LinkingTo" & type == "LinkingTo") |
    (existing_type == "LinkingTo" & type != "LinkingTo")

  changed <- FALSE

  # One of:
  # * No existing dependency
  # * Adding existing non-LinkingTo dependency to LinkingTo
  # * New use of a LinkingTo package as a non-LinkingTo dependency
  # In all cases, we can can simply make the change.
  if (!any(existing_dep) || any(is_linking_to)) {
    ui_done("Adding {ui_value(package)} to {ui_field(type)} field in DESCRIPTION")
    desc$set_dep(package, type, version = version)
    desc$write()
    changed <- TRUE
    return(invisible(changed))
  }

  # Request to add a dependency that is already in LinkingTo and only in
  # LinkingTo as a LinkingTo dependency --> no need to do anything.
  if (identical(existing_type, "LinkingTo") && type == "LinkingTo") {
     ui_done(
       "Package {ui_value(package)} is already listed in \\
        {ui_value('LinkingTo')} in DESCRIPTION, no change made."
      )
    return(invisible(changed))
  }

  existing_type <- setdiff(existing_type, "LinkingTo")
  delta <- sign(match(existing_type, types) - match(type, types))
  if (delta < 0) {
    # don't downgrade
    ui_warn(
      "Package {ui_value(package)} is already listed in \\
      {ui_value(existing_type)} in DESCRIPTION, no change made."
    )
  } else if (delta == 0 && !is.null(min_version)) {
    # change version
    upgrade <- existing_ver == "*" || numeric_version(min_version) > version_spec(existing_ver)
    if (upgrade) {
      ui_done(
        "Increasing {ui_value(package)} version to {ui_value(version)} in DESCRIPTION"
      )
      desc$set_dep(package, type, version = version)
      desc$write()
      changed <- TRUE
    }
  } else if (delta > 0) {
    # upgrade
    if (existing_type != "LinkingTo") {
      ui_done(
        "
        Moving {ui_value(package)} from {ui_field(existing_type)} to {ui_field(type)} \\
        field in DESCRIPTION
        "
      )
      desc$del_dep(package, existing_type)
      desc$set_dep(package, type, version = version)
      desc$write()
      changed <- TRUE
    }
  }

  invisible(changed)
}

r_version <- function() {
  version <- getRversion()
  glue("{version$major}.{version$minor}")
}

version_spec <- function(x) {
  x <- gsub("(<=|<|>=|>|==)\\s*", "", x)
  numeric_version(x)
}

view_url <- function(..., open = is_interactive()) {
  url <- paste(..., sep = "/")
  if (open) {
    ui_done("Opening URL {ui_value(url)}")
    utils::browseURL(url)
  } else {
    ui_todo("Open URL {ui_value(url)}")
  }
  invisible(url)
}
