#' Create a template for package documentation
#'
#' @param templateName Character, name of template and file
#'
#' @return This function creates a `.R` file in the directory "man-roxygen". If
#' that directory does not already exist in your package, it will create it.
#' The function opens the new (blank) file in your editor.
#'
#' @seealso \code{\link{file.edit}}
#' @export
#'
use_RdTemplate <- function(templateName){
  if(!dir.exists("man-roxygen")){
    dir.create("man-roxygen")
  }
  pth <- paste0("man-roxygen/", templateName, ".R")
  file.create(pth)
  utils::file.edit(pth)
}
