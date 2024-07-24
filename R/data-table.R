#' Prepare for importing data.table
#'
#' `use_data_table()` imports the `data.table()` function from the data.table
#' package, as well as several important symbols: `:=`, `.SD`, `.BY`, `.N`,
#' `.I`, `.GRP`, `.NGRP`, `.EACHI`. This is a minimal setup and you can learn
#' much more in the "Importing data.table" vignette:
#' `https://rdatatable.gitlab.io/data.table/articles/datatable-importing.html`.
#' In addition to importing these functions, `use_data_table()` also blocks the
#' usage of data.table in the `Depends` field of the `DESCRIPTION` file;
#' `data.table` should be used as an _imported_ or _suggested_ package only. See
#' this [discussion](https://github.com/Rdatatable/data.table/issues/3076).
#'
#' @export
use_data_table <- function() {
  check_is_package("use_data_table()")
  check_installed("data.table")
  check_uses_roxygen("use_data_table()")

  desc <- proj_desc()
  deps <- desc$get_deps()

  if (any(deps$type == "Depends" & deps$package == "data.table")) {
    ui_bullets(c(
      "!" = "{.pkg data.table} should be in {.field Imports} or
             {.field Suggests}, not {.field Depends}!",
      "v" = "Removing {.pkg data.table} from {.field Depends}."
    ))
    desc$del_dep("data.table", "Depends")
    desc$write()
  }

  use_import_from(
    "data.table",
    c("data.table", ":=", ".SD", ".BY", ".N", ".I", ".GRP", ".NGRP", ".EACHI")
  )
}
