#' Prepare for importing data.table
#'
#' @description `use_data_table` facilitates importing `data.table` by
#' handling up-front some common set-up tasks for using it in your package.
#'
#' This function does two main things:
#'
#' 1. Import the entire `data.table` namespace (with `@import`).
#'
#' 2. Block the usage of `data.table` as a dependency (`DESCRIPTION`
#' field `Depends`); `data.table` should be used as an _import_ or _suggested_
#' package only. See this [discussion](https://github.com/Rdatatable/data.table/issues/3076).
#' @export
use_data_table <- function() {
  check_is_package("use_data_table()")
  check_uses_roxygen("use_data_table()")

  deps <- desc::desc_get_deps(".")
  if (any(deps$type == 'Depends' & deps$package == "data.table")) {
    ui_warn("data.table should be in Imports or Suggests, not Depends")
    desc::desc_del_dep("data.table", "Depends", file = proj_get())
  }
  use_dependency("data.table", "Imports")
  new <- use_template("data-table.R", "R/utils-data-table.R")
  ui_todo("Run {ui_code('devtools::document()')}")
  invisible(new)
}
