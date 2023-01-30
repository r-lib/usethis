#' Use a standalone file from another repo
#'
#' A "standalone" file implements a minimum set of functionality in such a way
#' that it can be copied into another package. `use_standalone()` makes it easy
#' to get such a file into your own repo.
#'
#' @inheritParams create_from_github
#' @param file Name of standalone file. The `standalone-` prefix and file
#'   extension are optional. If omitted, will allow you to choose from the
#'   standalone files offered by that repo.
#' @export
use_standalone <- function(repo_spec, file = NULL) {
  proj_get() # force project discovery

  if (is.null(file)) {
    file <- standalone_choose()
  } else {
    if (path_ext(file) == "") {
      file <- path_ext_set(file, "R")
    }
    if (!startsWith(file, "standalone-")) {
      file <- paste0("standalone-", file)
    }
  }

  path <- path("R", paste0("import-", file))

  lines <- read_github_file(repo_spec, path = path)
  lines <- c(standalone_header(repo_spec, path), lines)
  write_over(proj_path(path), lines, overwrite = TRUE)

  dependencies <- standalone_dependencies(lines, path)
  for (dependency in dependencies) {
    use_standalone(repo_spec, dependency)
  }

  invisible()
}

standalone_choose <- function(repo_spec, error_call = parent.frame()) {
  json <- gh::gh(
    "/repos/{repo_spec}/contents/{path}",
    repo_spec = repo_spec,
    path = "R/"
  )

  names <- map_chr(json, "name")
  names <- names[grepl("^standalone-", names)]
  choices <- gsub("^standalone-|.[Rr]$", "", names)

  if (length(choices) == 0) {
    cli::cli_abort(
      "No standalone files found in {repo_spec}.",
      call = error_call
    )
  }

  if (!is_interactive()) {
    cli::cli_abort(
      c(
        "`file` is absent, but must be suppled.",
        i = "Possible options are {.or {choices}}."
      ),
      call = error_call
    )
  }

  choice <- utils::menu(
    choices = choices,
    title = "Which standalone file do you want to use (0 to exit)"
  )
  if (choice == 0) {
    cli::cli_abort("Selection cancelled")
  }

  names[choice]
}

standalone_header <- function(repo_spec, path) {
  c(
    "# Standalone file: do not edit by hand",
    glue("# Source: <https://github.com/{repo_spec}/blob/main/{path}>"),
    paste0("# ", strrep("-", 72 - 2)),
    "#"
  )
}

standalone_dependencies <- function(lines, path, call = caller_env()) {
  dividers <- which(lines == "# ---")
  if (length(dividers) != 2) {
    cli::cli_abort("Can't find yaml metadata in {.path {path}}.", call = call)
  }

  header <- lines[dividers[[1]]:dividers[[2]]]
  header <- gsub("^# ", "", header)

  temp <- withr::local_tempfile(lines = header)
  yaml <- rmarkdown::yaml_front_matter(temp)

  deps <- yaml$dependencies
  if (!is.null(deps) && !is.character(deps)) {
    cli::cli_abort("Invalid dependencies specification in {.path {path}}.", call = call)
  }
  deps %||% character()
}
