use_dependency <- function(package, type, min_version = NULL) {
  check_name(package)
  check_name(type)

  if (package != "R") {
    check_installed(package)
  }

  if (package == "R" && tolower(type) != "depends") {
    ui_abort('Set {.code type = "Depends"} when specifying an R version.')
  } else if (package == "R" && is.null(min_version)) {
    ui_abort('Specify {.arg min_version} when {.code package = "R"}.')
  }

  if (isTRUE(min_version) && package == "R") {
    min_version <- r_version()
  } else if (isTRUE(min_version)) {
    min_version <- utils::packageVersion(package)
  }
  version <- if (is.null(min_version) || isFALSE(min_version)) {
    "*"
  } else {
    glue(">= {min_version}")
  }

  types <- c("Depends", "Imports", "Suggests", "Enhances", "LinkingTo")
  names(types) <- tolower(types)
  type <- types[[match.arg(tolower(type), names(types))]]

  desc <- proj_desc()
  deps <- desc$get_deps()
  deps <- deps[deps$package == package, ]

  new_linking_to <- type == "LinkingTo" && !"LinkingTo" %in% deps$type
  new_non_linking_to <- type != "LinkingTo" && identical(deps$type, "LinkingTo")

  changed <- FALSE

  # One of:
  # * No existing dependency on this package
  # * Adding existing non-LinkingTo dependency to LinkingTo
  # * First use of a LinkingTo package as a non-LinkingTo dependency
  # In all cases, we can can simply make the change.
  if (nrow(deps) == 0 || new_linking_to || new_non_linking_to) {
    ui_bullets(c(
      "v" = "Adding {.pkg {package}} to {.field {type}} field in DESCRIPTION."
    ))
    desc$set_dep(package, type, version = version)
    desc$write()
    changed <- TRUE
    return(invisible(changed))
  }

  if (type == "LinkingTo") {
    deps <- deps[deps$type == "LinkingTo", ]
  } else {
    deps <- deps[deps$type != "LinkingTo", ]
  }
  existing_type <- deps$type
  existing_version <- deps$version

  delta <- sign(match(existing_type, types) - match(type, types))
  if (delta < 0) {
    # don't downgrade
    ui_bullets(c(
      "!" = "Package {.pkg {package}} is already listed in
             {.field {existing_type}} in DESCRIPTION; no change made."
    ))
  } else if (
    delta == 0 && version_spec(version) != version_spec(existing_version)
  ) {
    if (version_spec(version) > version_spec(existing_version)) {
      direction <- "Increasing"
    } else {
      direction <- "Decreasing"
    }

    ui_bullets(c(
      "v" = "{direction} {.pkg {package}} version to {.val {version}} in
             DESCRIPTION."
    ))
    desc$set_dep(package, type, version = version)
    desc$write()
    changed <- TRUE
  } else if (delta > 0) {
    # moving from, e.g., Suggests to Imports
    ui_bullets(c(
      "v" = "Moving {.pkg {package}} from {.field {existing_type}} to
             {.field {type}} field in DESCRIPTION."
    ))
    desc$del_dep(package, existing_type)
    desc$set_dep(package, type, version = version)
    desc$write()
    changed <- TRUE
  }

  invisible(changed)
}

r_version <- function() {
  version <- getRversion()
  glue("{version$major}.{version$minor}")
}

version_spec <- function(x) {
  if (x == "*") {
    x <- "0"
  }
  x <- gsub("(<=|<|>=|>|==)\\s*", "", x)
  numeric_version(x)
}

view_url <- function(..., open = is_interactive()) {
  url <- paste(..., sep = "/")
  if (open) {
    ui_bullets(c("v" = "Opening URL {.url {url}}."))
    utils::browseURL(url)
  } else {
    ui_bullets(c("_" = "Open URL {.url {url}}."))
  }
  invisible(url)
}
