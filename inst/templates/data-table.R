#' data.table special symbols
#'
#' These special symbols are used within [] in data.table;
#'   see ?data.table::.N for details about the usage of each;
#'   these need to be defined in your package to prevent the R CMD check
#'   warning about 'visible bindings for global variables' owing to
#'   non-standard evaluation. If you are also using un-quoted symbols in
#'   your package code, you'll want to set these to NULL as well, e.g.
#'     DT[ , x := 4]
#'   will create a warning about x not having a visible binding; resolve
#'   this by defining x=NULL either in your package's top-level environment
#'   or within the function body where it's used. See the vignette
#'   on importing data.table for more: vignette('datatable-importing')
#'
#' If you use := , we recommend defining this yourself rather than importing
#'   the value defined in data.table:
#' `:=` = function(...) NULL
#'
#' @importFrom data.table .N .I .BY .GRP .SD
#' @aliases               .N .I .BY .GRP .SD
#'
#' @importFrom data.table data.table
#' @aliases               data.table
#'
#' @name data.table
NULL
