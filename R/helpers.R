use_dependency <- function(package, type, min_version = NULL) {
  stopifnot(is_string(package))
  stopifnot(is_string(type))

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

  # No existing dependency, so can simply add
  if (!any(existing_dep) || any(is_linking_to)) {
    ui_done("Adding {ui_value(package)} to {ui_field(type)} field in DESCRIPTION")
    desc$set_dep(package, type, version = version)
    desc$write()
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
      desc$set_dep(package, type, version = version)
      desc$write()
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
    }
  }

  invisible(TRUE)
}

r_version <- function() {
  version <- getRversion()
  glue("{version$major}.{version$minor}")
}

use_system_requirement <- function(requirement) {
  stopifnot(is_string(requirement))

  desc <- proj_desc()
  existing <- desc$get_list("SystemRequirements", default = "")
  if (requirement %in% existing) {
    return(invisible())
  }

  ui_done(
    "Adding {ui_value(requirement)} to {ui_field('SystemRequirements')} field in DESCRIPTION"
  )
  desc$set_list("SystemRequirements", c(existing, requirement))
  desc$write()

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
