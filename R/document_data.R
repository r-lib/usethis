#' document_data
#'
#' @name document_data
#' @title Document data
#' @description
#' Create an .R file containing information gathered from
#' the data set to document. The variables' names are inserted
#' in a roxygen template to facilitate the documentation process,
#' and the row and column numbers are added to the description.
#'
#'
#' @param x the name of data set to document. The dataset
#'  must be load in the R environment.
#' @return an R file named as same as the dataset.
#' @export
#'
#'
#' @examples
#'\dontrun{
#' the_data <- as.data.frame(datasets::Titanic)
#' document_data(the_data)
#'}
#'@md
NULL

document_data <- function(x) {

document <-
    paste0(
      "
#'", "@","title ", substitute(x),"
#' ", "@", "description describe your data set here
#' ", "@","docType data
#' ", "@","usage data(",substitute(x),")
#' ", "@","format A tibble with ", length(x), " rows and ", length(names(x))," variables:
#' ", "//describe","{","\n#' ",
      paste0("\\item{",colnames(x),"}{Type label here}",
            collapse =paste0("\n","#' ")),
      "\n#'", "}","\n",
      "'",
      substitute(x),
      "'")

  cat(document, file = paste("./", substitute(x),".R"))

}


