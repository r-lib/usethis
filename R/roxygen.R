#' Use roxygen with markdown
#'
#' You'll need to manually re-document once enabled. If you are already using
#' roxygen2, but not with markdown, the roxygen2md package will be used to
#' convert many Rd expressions to markdown. The package uses heuristics so
#' you'll need to check the results.
#'
#' @inheritParams use_template
#' @export
use_roxygen_md <- function(base_path = ".") {
  check_installed("roxygen2")

  if (!uses_roxygen(base_path)) {
    desc::desc_set(
      Roxygen = "list(markdown = TRUE)",
      RoxygenNote = utils::packageVersion("roxygen2")
    )
    todo("Re-document")
  } else if (!uses_roxygen_md(base_path)) {
    check_installed("roxygen2md")
    roxygen2md::roxygen2md(base_path)
    todo("Re-document")
  }

  invisible()
}

uses_roxygen_md <- function(base_path = ".") {
  if (!desc::desc_has_fields("Roxygen", base_path))
    return(FALSE)

  roxygen <- desc::desc_get("Roxygen", base_path)[[1]]
  value <- tryCatch(
    {
      eval(parse(text = roxygen))
    },
    error = function(e) {
      NULL
    }
  )

  isTRUE(value$markdown)
}

uses_roxygen <- function(base_path = ".") {
  desc::desc_has_fields("RoxygenNote", base_path)
}
