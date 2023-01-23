
proj_desc <- function(path = proj_get()) {
  desc::desc(file = path)
}

proj_version <- function() {
  proj_desc()$get_field("Version")
}

proj_deps <- function() {
  proj_desc()$get_deps()
}

proj_desc_field_append <- function(key, value) {
  check_string(key)
  check_string(value)

  desc <- proj_desc()

  old <- desc$get_list(key, default = "")
  if (value %in% old) {
    return(invisible())
  }

  ui_done("Adding {ui_value(value)} to {ui_field(key)}")
  # https://github.com/r-lib/desc/issues/117
  desc$set_list(key, c(old, value))
  desc$write()

  invisible()
}
