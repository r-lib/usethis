proj_desc <- function(path = proj_get()) {
  desc::desc(file = path)
}

proj_version <- function() {
  proj_desc()$get_field("Version")
}

proj_deps <- function() {
  proj_desc()$get_deps()
}

proj_desc_create <- function(name, fields = list(), roxygen = TRUE) {
  fields <- use_description_defaults(name, roxygen = roxygen, fields = fields)

  # https://github.com/r-lib/desc/issues/132
  desc <- desc::desc(text = glue("{names(fields)}: {fields}"))
  tidy_desc(desc)

  tf <- withr::local_tempfile()
  desc$write(file = tf)
  write_over(proj_path("DESCRIPTION"), read_utf8(tf))

  # explicit check of "usethis.quiet" since I'm not doing the printing
  if (!is_quiet()) {
    desc$print()
  }
}

# Here overwrite means "update the field if there is already a value in it,
# including appending".
proj_desc_field_update <- function(key, value, overwrite = TRUE, append = FALSE) {
  check_string(key)
  check_character(value)
  check_bool(overwrite)

  desc <- proj_desc()

  old <- desc$get_list(key, default = "")
  if (all(value %in% old)) {
    return(invisible())
  }

  if (!overwrite && length(old) > 0 && any(old != "")) {
    ui_abort("
      {.field {key}} has a different value in DESCRIPTION.
      Use {.code overwrite = TRUE} to overwrite.")
  }

  ui_bullets(c("v" = "Adding {.val {value}} to {.field {key}}."))

  if (append) {
    value <- union(old, value)
  }

  # https://github.com/r-lib/desc/issues/117
  desc$set_list(key, value)
  desc$write()

  invisible()
}
