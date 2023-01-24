proj_desc <- function(path = proj_get()) {
  UsethisDescription$new(file = path)
}

UsethisDescription <- R6::R6Class(
  classname = "UsethisDescription",
  inherit = desc::description,
  public = list(
    write = function(file = NULL) {
      if (self$get_field("Config/usethis/tidy-description", "") == "true") {
        self$set("Encoding" = "UTF-8")

        # Normalize all fields (includes reordering)
        # Wrap in a try() so it always succeeds, even if user options are malformed
        try(self$normalize(), silent = TRUE)
      }

      super$write(file = file)
    }
  )
)

proj_version <- function() {
  proj_desc()$get_field("Version")
}

proj_deps <- function() {
  proj_desc()$get_deps()
}

proj_desc_create <- function(name, fields = list(), roxygen = TRUE) {
  fields <- use_description_defaults(name, roxygen = roxygen, fields = fields)

  # https://github.com/r-lib/desc/issues/132
  desc <- UsethisDescription$new(text = glue("{names(fields)}: {fields}"))

  tf <- withr::local_tempfile()
  desc$write(file = tf)
  write_over(proj_path("DESCRIPTION"), read_utf8(tf))

  # explicit check of "usethis.quiet" since I'm not doing the printing
  if (!getOption("usethis.quiet", default = FALSE)) {
    desc$print()
  }
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
