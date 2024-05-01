#' Create Citation File Format
#'
#' `use_cff()` ...
#'
#' @seealso The [data chapter](https://r-pkgs.org/data.html) of [R
#'   Packages](https://r-pkgs.org).
#' @export
#' @examples
#' \dontrun{
#' use_cff()
#' }
use_cff <- function() {
    check_is_package() # CM: Other functions start with this, but not sure if I need it
    use_template(
        "CITATION-template.cff",
        "CITATION.cff",
        open = TRUE
    )

    ui_bullets(c(
        "_" = "Edit `CITATION.cff` (see {.url https://book.the-turing-way.org/communication/citable/citable-cffinit.html} and {.url https://citation-file-format.github.io/cff-initializer-javascript/#/})."
    ))
}
