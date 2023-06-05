#' Use roxygen2 with markdown
#'
#' If you are already using roxygen2, but not with markdown, you'll need to use
#' [roxygen2md](https://roxygen2md.r-lib.org) to convert existing Rd expressions
#' to markdown. The conversion is not perfect, so make sure to check the
#' results.
#'
#' @param overwrite Whether to overwrite an existing `Roxygen` field in
#'   `DESCRIPTION` with `"list(markdown = TRUE)"`.
#'
#'
#' @export
use_roxygen_md <- function(overwrite = FALSE) {
  check_installed("roxygen2")

  if (!uses_roxygen()) {
    roxy_ver <- as.character(utils::packageVersion("roxygen2"))

    proj_desc_field_update("Roxygen", "list(markdown = TRUE)", overwrite = FALSE)
    proj_desc_field_update("RoxygenNote", roxy_ver, overwrite = FALSE)
    ui_todo("Run {ui_code('devtools::document()')}")
    return(invisible())
  }

  already_setup <- uses_roxygen_md()

  if (isTRUE(already_setup)) {
    return(invisible())
  }

  if (isFALSE(already_setup) || isTRUE(overwrite)) {
    proj_desc_field_update("Roxygen", "list(markdown = TRUE)", overwrite = TRUE)

    check_installed("roxygen2md")
    ui_todo("
      Run {ui_code('roxygen2md::roxygen2md()')} to convert existing Rd \\
      comments to markdown")
    if (!uses_git()) {
      ui_todo("
        Consider using Git for greater visibility into and control over the \\
        conversion process")
    }
    ui_todo("Run {ui_code('devtools::document()')} when you're done")

    return(invisible())
  }

  ui_stop("
    {ui_path('DESCRIPTION')} already has a {ui_field('Roxygen')} field
    Delete it and try again or call {ui_code('use_roxygen_md(overwrite = TRUE)')}")

  invisible()
}

# FALSE: no Roxygen field
# TRUE: plain old "list(markdown = TRUE)"
# NA: everything else
uses_roxygen_md <- function() {
  desc <- proj_desc()

  if (!desc$has_fields("Roxygen")) {
    return(FALSE)
  }

  roxygen <- desc$get_field("Roxygen", "")
  if (identical(roxygen, "list(markdown = TRUE)") ||
      identical(roxygen, "list(markdown = TRUE, r6 = FALSE)")) {
    TRUE
  } else {
    NA
  }
}

uses_roxygen <- function() {
  proj_desc()$has_fields("RoxygenNote")
}

roxygen_ns_append <- function(tag) {
  block_append(
    glue("{ui_value(tag)}"),
    glue("#' {tag}"),
    path = proj_path(package_doc_path()),
    block_start = "## usethis namespace: start",
    block_end = "## usethis namespace: end",
    block_suffix = "NULL",
    sort = TRUE
  )
}

roxygen_ns_show <- function() {
  block_show(
    path = proj_path(package_doc_path()),
    block_start = "## usethis namespace: start",
    block_end = "## usethis namespace: end"
  )
}

roxygen_remind <- function() {
  ui_todo("Run {ui_code('devtools::document()')} to update {ui_path('NAMESPACE')}")
  TRUE
}

roxygen_update_ns <- function(load = is_interactive()) {
  ui_done("Writing {ui_path('NAMESPACE')}")
  utils::capture.output(
    suppressMessages(roxygen2::roxygenise(proj_get(), "namespace"))
  )

  if (load) {
    ui_done("Loading {project_name()}")
    pkgload::load_all(path = proj_get(), quiet = TRUE)
  }

  TRUE
}

# Checkers ----------------------------------------------------------------

check_uses_roxygen <- function(whos_asking) {
  force(whos_asking)

  if (uses_roxygen()) {
    return(invisible())
  }

  ui_stop(
    "
    Project {ui_value(project_name())} does not use roxygen2.
    {ui_code(whos_asking)} can not work without it.
    You might just need to run {ui_code('devtools::document()')} once, then try again.
    "
  )
}
