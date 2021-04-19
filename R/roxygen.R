#' Use roxygen2 with markdown
#'
#' If you are already using roxygen2, but not with markdown, you'll need to use
#' [roxygen2md](https://roxygen2md.r-lib.org) to convert existing Rd
#' expressions to markdown. The conversion is not perfect, so make sure
#' to check the results.
#'
#' @export
use_roxygen_md <- function() {
  check_installed("roxygen2")

  if (!uses_roxygen()) {
    roxy_ver <- as.character(utils::packageVersion("roxygen2"))

    use_description_field("Roxygen", "list(markdown = TRUE)")
    use_description_field("RoxygenNote", roxy_ver)
    ui_todo("Run {ui_code('devtools::document()')}")
  } else if (!uses_roxygen_md()) {
    use_description_field("Roxygen", "list(markdown = TRUE)")

    if (!uses_git()) {
      ui_todo("Use git to ensure that you don't lose any data")
    }

    check_installed("roxygen2md")
    ui_todo(
      "Run {ui_code('roxygen2md::roxygen2md()')} to convert existing Rd commands to RMarkdown"
    )
    ui_todo("Run {ui_code('devtools::document()')} when you're done.")
  }

  invisible()
}

uses_roxygen_md <- function(base_path = proj_get()) {
  if (!desc::desc_has_fields("Roxygen", base_path)) {
    return(FALSE)
  }

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

uses_roxygen <- function(base_path = proj_get()) {
  desc::desc_has_fields("RoxygenNote", base_path)
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
    pkgload::load_all(quiet = TRUE)
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
