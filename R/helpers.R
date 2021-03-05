use_description_field <- function(name,
                                  value,
                                  base_path = proj_get(),
                                  overwrite = FALSE) {
  # account for `value`s produced via `glue::glue()`
  value <- as.character(value)
  curr <- desc::desc_get(name, file = base_path)[[1]]
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
  desc::desc_set(name, value, file = base_path)
  invisible()
}

use_dependency <- function(package, type, min_version = NULL) {
  stopifnot(is_string(package))
  stopifnot(is_string(type))

  if (package != "R") {
    check_installed(package)
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
  is_linking_to <- (existing_type != "LinkingTo" & type == "LinkingTo") |
    (existing_type == "LinkingTo" & type != "LinkingTo")

  # No existing dependency, so can simply add
  if (!any(existing_dep) || any(is_linking_to)) {
    ui_done("Adding {ui_value(package)} to {ui_field(type)} field in DESCRIPTION")
    desc::desc_set_dep(package, type, version = version, file = proj_get())
    return(invisible(TRUE))
  }

  existing_type <- setdiff(existing_type, "LinkingTo")
  delta <- sign(match(existing_type, types) - match(type, types))
  if (delta < 0) {
    # don't downgrade
    ui_warn(
      "Package {ui_value(package)} is already listed in \\
      {ui_value(existing_type)} in DESCRIPTION, no change made."
    )

    return(invisible(FALSE))
  } else if (delta == 0 && !is.null(min_version)) {
    # change version
    upgrade <- existing_ver == "*" || numeric_version(min_version) > version_spec(existing_ver)
    if (upgrade) {
      ui_done(
        "Increasing {ui_value(package)} version to {ui_value(version)} in DESCRIPTION"
      )
      desc::desc_set_dep(package, type, version = version, file = proj_get())
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
      desc::desc_del_dep(package, existing_type, file = proj_get())
      desc::desc_set_dep(package, type, version = version, file = proj_get())
    }
  }

  invisible(TRUE)
}

use_system_requirement <- function(requirement) {
  stopifnot(is_string(requirement))
  existing_requirements <- desc::desc_get_field("SystemRequirements", default = character(), file = proj_get())
  existing_requirements <- utils::head(strsplit(existing_requirements, ", ?"), n = 1)

  if (requirement %in% existing_requirements) {
    return(invisible())
  }

  new_requirements <- paste0(c(existing_requirements, requirement), collapse = ", ")

  ui_done(
    "Adding {ui_value(requirement)} to {ui_field('SystemRequirements')} field in DESCRIPTION"
  )

  desc::desc_set("SystemRequirements", new_requirements)

  invisible()
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
