#' Prepare for importing data.table
#'
#' @description `use_data_table` facilitates importing `data.table` by
#' handling up-front some common set-up tasks for using it in your package.
#'
#' @details This function does three main things:
#'
#' (1) `data.table` non-standard evaluation (NSE) can lead to some
#' `NOTE`s from `R CMD check`; e.g., the common idiom `DT[ , .N, by = grp]` to
#' count rows grouping by the column `grp` uses the symbol `.N`;
#' `R CMD check` sees this value is used but undefined and complains. To get
#' around this, we import this symbol from `data.table`'s namespace.
#'
#' (2) Import the `data.table` function (the most fundamental function
#' from the package)
#'
#' (3) Block the usage of `data.table` as a dependency (`DESCRIPTION`
#' field `Depends`); `data.table` should be used as an _import_ or _suggested_
#' package only.

#' @export
use_data_table = function() {
  check_is_package("use_data_table()")
  deps = desc::desc_get_deps('.')
  if (any(deps$type == 'Depends' & deps$package == 'data.table')) {
    ui_warn("data.table should be in Imports or Suggests, not Depends")
    desc::desc_del_dep('data.table', 'Depends', file = proj_get())
  }
  use_dependency('data.table', 'Imports')
  new <- use_template('data-table.R', 'R/utils-data-table.R')
  ui_todo("Run {ui_code('devtools::document()')}")
  return(invisible(new))
}
