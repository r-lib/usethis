
#' Use NEWS.md
#'
#' This creates \code{NEWS.md} from a template.
#'
#' @param pkg package description, can be path or package name.  See
#'   \code{\link{as.package}} for more information
#' @export
#' @family infrastructure
use_news_md <- function(pkg = ".") {
  pkg <- as.package(pkg)

  use_template("NEWS.md", data = pkg, open = TRUE, pkg = pkg)
}
