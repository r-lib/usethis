#' Prepare for importing data.table
#'
#' @description
#'
#' `use_data_table()` imports the `data.table()` function from the data.table
#' package, as well as several important symbols: `:=`, `.SD`, `.BY`, `.N`,
#' `.I`, `.GRP`, `.NGRP`, `.EACHI`. This is a minimal setup to get `data.table`s
#' working with your package. See the [importing
#' data.table](https://rdatatable.gitlab.io/data.table/articles/datatable-importing.html)
#' vignette for other strategies. In addition to importing these function,
#' `use_data_table()` also blocks the usage of data.table in the `Depends` field
#' of the `DESCRIPTION` file; `data.table` should be used as an _imported_ or
#' _suggested_ package only. See this
#' [discussion](https://github.com/Rdatatable/data.table/issues/3076).
#' @export
use_data_table <- function() {
  check_is_package("use_data_table()")
  check_uses_roxygen("use_data_table()")

  deps <- desc::desc_get_deps(".")
  if (any(deps$type == "Depends" & deps$package == "data.table")) {
    ui_warn("data.table should be in Imports or Suggests, not Depends")
    ui_done("Deleting data.table from {ui_field('Depends')}")
    desc::desc_del_dep("data.table", "Depends", file = proj_get())
  }

  use_import_from(
    "data.table",
    c("data.table", ":=", ".SD", ".BY", ".N", ".I", ".GRP", ".NGRP", ".EACHI")
  )
}
